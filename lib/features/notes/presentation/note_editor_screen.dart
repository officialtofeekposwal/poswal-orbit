import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/app_sheet.dart';
import 'package:poswal_orbit/core/widgets/app_toolbar.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/data/repositories/note_repository.dart';
import 'package:poswal_orbit/domain/logic/markdown_editor_engine.dart';
import 'package:poswal_orbit/domain/logic/markdown_lite.dart';
import 'package:poswal_orbit/domain/models/note_models.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_detail_screen.dart';
import 'package:poswal_orbit/features/notes/application/note_providers.dart';
import 'package:poswal_orbit/features/tasks/application/task_providers.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';
import 'package:poswal_orbit/features/notes/presentation/widgets/markdown_text_editing_controller.dart';
import 'package:poswal_orbit/features/notes/presentation/widgets/note_formatting_toolbar.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  final Note? initialNote;

  const NoteEditorScreen({
    super.key,
    this.noteId,
    this.initialNote,
  });

  static Future<void> push(BuildContext context, {String? noteId, Note? initialNote}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(noteId: noteId, initialNote: initialNote),
      ),
    );
  }

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> with WidgetsBindingObserver {
  late final TextEditingController _titleController;
  late final MarkdownTextEditingController _bodyController;
  final FocusNode _bodyFocusNode = FocusNode();

  String _currentNoteId = '';
  int _colorLabel = NoteColorLabel.none;
  bool _isPinned = false;
  bool _isJournal = false;
  String? _journalDate;
  String? _linkedTaskId;
  String? _linkedHabitId;
  List<String> _tags = [];
  DateTime _createdAt = DateTime.now();

  bool _isSaving = false;
  bool _hasSaved = true;
  bool _isDisposed = false;
  Timer? _debounceTimer;
  late NoteRepository _noteRepo;

  @override
  void initState() {
    super.initState();
    _noteRepo = ref.read(noteRepositoryProvider);
    WidgetsBinding.instance.addObserver(this);

    final note = widget.initialNote;
    _currentNoteId = widget.noteId ?? note?.id ?? '';
    _titleController = TextEditingController(text: note?.title ?? '');
    _bodyController = MarkdownTextEditingController(text: note?.body ?? '');

    if (note != null) {
      _colorLabel = note.colorLabel;
      _isPinned = note.isPinned;
      _isJournal = note.isJournal;
      _journalDate = note.journalDate;
      _linkedTaskId = note.linkedTaskId;
      _linkedHabitId = note.linkedHabitId;
      _tags = List.from(note.tags);
      _createdAt = note.createdAt;
    }

    _titleController.addListener(_onTextChanged);
    _bodyController.addListener(_onTextChanged);

    // If ID was passed without initialNote, load it from SQLite
    if (widget.noteId != null && widget.initialNote == null) {
      _loadExistingNote();
    }
  }

  Future<void> _loadExistingNote() async {
    final repo = _noteRepo;
    final note = await repo.getNoteById(widget.noteId!);
    if (note != null && mounted) {
      setState(() {
        _titleController.text = note.title;
        _bodyController.text = note.body;
        _colorLabel = note.colorLabel;
        _isPinned = note.isPinned;
        _isJournal = note.isJournal;
        _journalDate = note.journalDate;
        _linkedTaskId = note.linkedTaskId;
        _linkedHabitId = note.linkedHabitId;
        _tags = List.from(note.tags);
        _createdAt = note.createdAt;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveNoteImmediate();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _saveNoteImmediate(); // Zero data loss on dispose/kill
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_hasSaved && mounted && !_isDisposed) {
      setState(() {
        _hasSaved = false;
      });
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(PoswalDurations.debounce, () {
      _saveNoteImmediate();
    });
  }

  Future<void> _saveNoteImmediate() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text;

    // Don't save empty blank notes that have never been created
    if (title.isEmpty && body.trim().isEmpty && _currentNoteId.isEmpty) {
      return;
    }

    if (mounted && !_isDisposed) {
      setState(() {
        _isSaving = true;
      });
    }

    final repo = _noteRepo;
    final now = DateTime.now();

    final note = Note(
      id: _currentNoteId,
      title: title,
      body: body,
      colorLabel: _colorLabel,
      isPinned: _isPinned,
      isJournal: _isJournal,
      journalDate: _journalDate,
      linkedTaskId: _linkedTaskId,
      linkedHabitId: _linkedHabitId,
      tags: _tags,
      createdAt: _createdAt,
      updatedAt: now,
    );

    if (_currentNoteId.isEmpty) {
      final created = await repo.createNote(note, tagNames: _tags);
      _currentNoteId = created.id;
    } else {
      await repo.updateNote(note, tagNames: _tags);
    }

    if (mounted && !_isDisposed) {
      setState(() {
        _isSaving = false;
        _hasSaved = true;
      });
    }
  }

  // --- Smart Enter in Lists ---

  void _handleSmartEnter(String text, TextSelection selection) {
    final result = MarkdownEditorEngine.handleSmartEnter(text, selection);
    if (result != null) {
      _bodyController.value = TextEditingValue(
        text: result.text,
        selection: result.selection,
      );
      _onTextChanged();
    }
  }

  void _onEditorTap() {
    final text = _bodyController.text;
    final selection = _bodyController.selection;
    if (selection.isCollapsed && selection.start >= 0) {
      final result = MarkdownEditorEngine.toggleChecklistStateAtCursor(text, selection.start);
      if (result != null) {
        unawaited(HapticFeedback.lightImpact());
        _bodyController.value = TextEditingValue(
          text: result.text,
          selection: result.selection,
        );
        _onTextChanged();
      }
    }
  }

  void _openColorPicker() {
    HapticFeedback.selectionClick();
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AppSheet(
          title: l10n?.noteColorLabelTitle ?? 'Note Color Label',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: NoteColorLabel.values.map((label) {
                final colorVal = NoteColorLabel.toColorValue(label);
                final isSelected = _colorLabel == label;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _colorLabel = label;
                    });
                    _onTextChanged();
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: label == NoteColorLabel.none
                          ? (isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight)
                          : Color(colorVal),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            PhosphorIconsBold.check,
                            size: 16,
                            color: label == NoteColorLabel.none
                                ? (isDark ? Colors.white : Colors.black)
                                : Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _openAddTagDialog() {
    final tagCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? PoswalColors.surfaceDark
              : PoswalColors.surfaceLight,
          title: Text(l10n?.addTagTooltip ?? 'Add Tag', style: PoswalText.headline),
          content: TextField(
            controller: tagCtrl,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n?.addTagPlaceholder ?? 'e.g. project, ideas'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                final tag = tagCtrl.text.trim().toLowerCase().replaceAll('#', '');
                if (tag.isNotEmpty && !_tags.contains(tag)) {
                  setState(() {
                    _tags.add(tag);
                  });
                  _onTextChanged();
                }
                Navigator.pop(ctx);
              },
              child: Text(l10n?.addTag ?? 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _openLinkItemPicker() async {
    final habits = await ref.read(habitRepositoryProvider).watchActiveHabits().first;
    final tasks = await ref.read(taskRepositoryProvider).watchAllTasks().first;

    if (!mounted) return;

    unawaited(showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
        final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

        final l10n = AppLocalizations.of(context);

        return AppSheet(
          title: l10n?.linkHabitOrTaskTitle ?? 'Link to Habit or Task',
          isFullHeight: true,
          child: ListView(
            shrinkWrap: true,
            children: [
              // Active Habits
              if (habits.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md, vertical: PoswalSpacing.xs),
                  child: Text(l10n?.habitsSectionHeader ?? 'HABITS', style: PoswalText.caption.copyWith(color: textMuted)),
                ),
                ...habits.map((h) => ListTile(
                      leading: Icon(PhosphorIconsRegular.sparkle, color: Color(h.colorValue)),
                      title: Text(h.name, style: TextStyle(color: textPrimary)),
                      onTap: () {
                        setState(() {
                          _linkedHabitId = h.id;
                        });
                        _onTextChanged();
                        Navigator.pop(ctx);
                      },
                    )),
                const Divider(),
              ],

              // Active Tasks
              if (tasks.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md, vertical: PoswalSpacing.xs),
                  child: Text(l10n?.tasksSectionHeader ?? 'TASKS', style: PoswalText.caption.copyWith(color: textMuted)),
                ),
                ...tasks.map((t) => ListTile(
                      leading: Icon(PhosphorIconsRegular.checkSquare, color: Color(t.priority.colorValue)),
                      title: Text(t.title, style: TextStyle(color: textPrimary)),
                      onTap: () {
                        setState(() {
                          _linkedTaskId = t.id;
                        });
                        _onTextChanged();
                        Navigator.pop(ctx);
                      },
                    )),
              ],
            ],
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    // Detect RTL dynamically based on note title/body
    final isRtl = MarkdownLite.isRtlText(
      _bodyController.text.isNotEmpty ? _bodyController.text : _titleController.text,
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        _saveNoteImmediate();
      },
      child: AuroraBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. Top Glass App Bar
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: PoswalSpacing.md,
                    vertical: PoswalSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      // Back Button
                      IconButton(
                        key: const ValueKey('note_back_btn'),
                        icon: const Icon(PhosphorIconsRegular.caretLeft, size: 24),
                        color: textPrimary,
                        onPressed: () {
                          _saveNoteImmediate();
                          Navigator.pop(context);
                        },
                      ),

                      // Status indicator ("Saved" or "Saving...")
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: PoswalSpacing.xs),
                        child: AnimatedSwitcher(
                          duration: PoswalDurations.micro,
                          child: _isSaving
                              ? Text(
                                  l10n?.notesSaving ?? 'Saving...',
                                  key: const ValueKey('saving_indicator'),
                                  style: PoswalText.caption.copyWith(color: PoswalColors.gold),
                                )
                              : Text(
                                  l10n?.notesSaved ?? 'Saved',
                                  key: const ValueKey('saved_indicator'),
                                  style: PoswalText.caption.copyWith(color: PoswalColors.teal),
                                ),
                        ),
                      ),

                      const Spacer(),

                      // Grouped actions capsule (HIG AppToolbarButtonGroup)
                      AppToolbarButtonGroup(
                        buttons: [
                          IconButton(
                            key: const ValueKey('note_pin_btn'),
                            icon: Icon(
                              _isPinned ? PhosphorIconsFill.pushPin : PhosphorIconsRegular.pushPin,
                              size: 20,
                              color: _isPinned ? PoswalColors.gold : textMuted,
                            ),
                            tooltip: _isPinned ? 'Unpin' : 'Pin',
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _isPinned = !_isPinned;
                              });
                              _onTextChanged();
                            },
                          ),
                          IconButton(
                            key: const ValueKey('note_color_btn'),
                            icon: Icon(
                              PhosphorIconsRegular.palette,
                              size: 20,
                              color: _colorLabel != NoteColorLabel.none
                                  ? Color(NoteColorLabel.toColorValue(_colorLabel))
                                  : textMuted,
                            ),
                            tooltip: l10n?.colorLabelTooltip ?? 'Color Label',
                            onPressed: _openColorPicker,
                          ),
                          IconButton(
                            key: const ValueKey('note_link_btn'),
                            icon: Icon(
                              PhosphorIconsRegular.link,
                              size: 20,
                              color: (_linkedTaskId != null || _linkedHabitId != null)
                                  ? PoswalColors.violet
                                  : textMuted,
                            ),
                            tooltip: l10n?.linkHabitTaskTooltip ?? 'Link to Habit/Task',
                            onPressed: _openLinkItemPicker,
                          ),
                          IconButton(
                            key: const ValueKey('note_tag_btn'),
                            icon: const Icon(PhosphorIconsRegular.tag, size: 20),
                            color: textMuted,
                            tooltip: l10n?.addTagTooltip ?? 'Add Tag',
                            onPressed: _openAddTagDialog,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Editor Content
                Expanded(
                  child: Directionality(
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: PoswalSpacing.lg,
                        vertical: PoswalSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Linked Item Chips (if any)
                          if (_linkedHabitId != null || _linkedTaskId != null || _isJournal)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(bottom: PoswalSpacing.md),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  if (_isJournal)
                                    AppGlassChip(
                                      label: l10n?.dailyJournalHeader(_journalDate ?? '') ?? 'Daily Journal • ${_journalDate ?? ""}',
                                      icon: const Icon(PhosphorIconsRegular.bookOpen, size: 14),
                                      isSelected: true,
                                      onTap: () {},
                                    ),
                                  if (_linkedHabitId != null)
                                    AppGlassChip(
                                      key: const ValueKey('linked_habit_chip'),
                                      label: l10n?.linkedHabitLabel ?? 'Linked Habit',
                                      icon: const Icon(PhosphorIconsRegular.sparkle, size: 14),
                                      isSelected: true,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => HabitDetailScreen(habitId: _linkedHabitId!),
                                          ),
                                        );
                                      },
                                    ),
                                  if (_linkedTaskId != null)
                                    AppGlassChip(
                                      key: const ValueKey('linked_task_chip'),
                                      label: l10n?.linkedTaskLabel ?? 'Linked Task',
                                      icon: const Icon(PhosphorIconsRegular.checkSquare, size: 14),
                                      isSelected: true,
                                      onTap: () async {
                                        final task = await ref
                                            .read(taskRepositoryProvider)
                                            .getTaskById(_linkedTaskId!);
                                        if (task != null && context.mounted) {
                                          await showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (_) => TaskDetailSheet(task: task),
                                          );
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ),

                          // Tags Wrap
                          if (_tags.isNotEmpty)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(bottom: PoswalSpacing.sm),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: _tags.map((tag) {
                                  return Chip(
                                    label: Text('#$tag', style: PoswalText.caption),
                                    backgroundColor: isDark
                                        ? PoswalColors.surfaceDark2
                                        : PoswalColors.surfaceLight,
                                    deleteIcon: const Icon(PhosphorIconsRegular.x, size: 14),
                                    onDeleted: () {
                                      setState(() {
                                        _tags.remove(tag);
                                      });
                                      _onTextChanged();
                                    },
                                  );
                                }).toList(),
                              ),
                            ),

                          // Title Field
                          TextField(
                            key: const ValueKey('note_title_field'),
                            controller: _titleController,
                            style: PoswalText.largeTitle.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n?.noteTitleHint ?? 'Title',
                              hintStyle: PoswalText.largeTitle.copyWith(
                                color: textMuted.withValues(alpha: 0.6),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: null,
                          ),

                          const SizedBox(height: PoswalSpacing.md),

                          // Body Field with Smart Enter
                          TextField(
                            key: const ValueKey('note_body_field'),
                            controller: _bodyController,
                            focusNode: _bodyFocusNode,
                            style: PoswalText.bodyText.copyWith(
                              color: textPrimary,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n?.noteBodyHint ?? 'Start writing (Markdown-lite supported)...',
                              hintStyle: PoswalText.bodyText.copyWith(
                                color: textMuted.withValues(alpha: 0.6),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            onTap: _onEditorTap,
                            onChanged: (text) {
                              // Check if Enter key was hit at end of a checklist/bullet line
                              final selection = _bodyController.selection;
                              if (text.endsWith('\n') || (selection.start > 0 && text[selection.start - 1] == '\n')) {
                                _handleSmartEnter(text, selection);
                              }
                            },
                          ),

                          const SizedBox(height: 120), // Bottom space for floating toolbar
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Floating Glass Formatting Toolbar above Keyboard
                NoteFormattingToolbar(
                  controller: _bodyController,
                  focusNode: _bodyFocusNode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
