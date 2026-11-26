import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/app_search_field.dart';
import 'package:poswal_orbit/core/widgets/app_sheet.dart';
import 'package:poswal_orbit/core/widgets/app_toolbar.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/models/note_models.dart';
import 'package:poswal_orbit/features/notes/application/note_providers.dart';
import 'package:poswal_orbit/features/notes/presentation/note_editor_screen.dart';
import 'package:poswal_orbit/features/notes/presentation/widgets/note_card.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNoteActions(BuildContext context, Note note) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return AppSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                key: const ValueKey('note_action_pin'),
                leading: Icon(
                  note.isPinned ? PhosphorIconsFill.pushPin : PhosphorIconsRegular.pushPin,
                  color: PoswalColors.gold,
                ),
                title: Text(
                  note.isPinned ? (l10n?.unpinNote ?? 'Unpin Note') : (l10n?.pinNote ?? 'Pin Note'),
                  style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(noteRepositoryProvider).setPinned(note.id, !note.isPinned);
                },
              ),
              ListTile(
                key: const ValueKey('note_action_color'),
                leading: const Icon(PhosphorIconsRegular.palette, color: PoswalColors.violet),
                title: Text(
                  l10n?.changeColorLabel ?? 'Change Color Label',
                  style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showColorPicker(context, note);
                },
              ),
              const Divider(),
              ListTile(
                key: const ValueKey('note_action_delete'),
                leading: const Icon(PhosphorIconsRegular.trash, color: PoswalColors.danger),
                title: Text(
                  l10n?.deleteNote ?? 'Delete Note',
                  style: const TextStyle(color: PoswalColors.danger, fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final repo = ref.read(noteRepositoryProvider);
                  await repo.softDeleteNote(note.id);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight,
                        content: Text(
                          l10n?.noteDeletedToast ?? 'Note deleted',
                          style: TextStyle(color: textPrimary),
                        ),
                        action: SnackBarAction(
                          label: l10n?.undoButton ?? 'Undo',
                          textColor: PoswalColors.teal,
                          onPressed: () {
                            repo.restoreNote(note.id);
                          },
                        ),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorPicker(BuildContext context, Note note) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AppSheet(
          title: l10n?.colorLabelTitle ?? 'Color Label',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg, vertical: PoswalSpacing.md),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: NoteColorLabel.values.map((label) {
                final colorVal = NoteColorLabel.toColorValue(label);
                final isSelected = note.colorLabel == label;

                return GestureDetector(
                  onTap: () {
                    ref.read(noteRepositoryProvider).setColorLabel(note.id, label);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: label == NoteColorLabel.none
                          ? (isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight)
                          : Color(colorVal),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            PhosphorIconsRegular.check,
                            size: 18,
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

  void _openTodayJournal(BuildContext context) async {
    unawaited(HapticFeedback.selectionClick());
    final today = ref.read(selectedDateProvider);
    final dateStr = DateBoundary.toDateString(today);
    final note = await ref.read(noteRepositoryProvider).getOrCreateTodayJournalNote(dateStr);

    if (context.mounted) {
      unawaited(NoteEditorScreen.push(context, initialNote: note));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;

    final notesAsync = ref.watch(notesStreamProvider);
    final selectedTag = ref.watch(noteFilterTagProvider);

    return AuroraBackground(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Navigation / Control Layer: AppToolbar
            SliverToBoxAdapter(
              child: AppToolbar(
                title: Text(
                  l10n?.tabNotes ?? 'Notes',
                  style: PoswalText.largeTitle.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                actions: [
                  IconButton(
                    key: const ValueKey('notes_search_toggle'),
                    icon: Icon(
                      _isSearchOpen ? PhosphorIconsRegular.x : PhosphorIconsRegular.magnifyingGlass,
                      size: 20,
                      color: textPrimary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearchOpen = !_isSearchOpen;
                        if (!_isSearchOpen) {
                          _searchController.clear();
                          _searchQuery = '';
                        }
                      });
                    },
                  ),
                  AppGlassButton(
                    key: const ValueKey('today_journal_btn'),
                    padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md, vertical: PoswalSpacing.xs),
                    onPressed: () => _openTodayJournal(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(PhosphorIconsRegular.bookOpen, size: 14),
                        const SizedBox(width: 4),
                        Text(l10n?.tabToday ?? 'Today', style: PoswalText.caption),
                      ],
                    ),
                  ),
                ],
                showAddButton: true,
                addTooltip: 'Create Note',
                addKey: const ValueKey('notes_toolbar_add_btn'),
                onAddPressed: () => NoteEditorScreen.push(context),
              ),
            ),

            // Expandable Search Bar (HIG AppSearchField)
            if (_isSearchOpen)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg, vertical: PoswalSpacing.xs),
                  child: AppSearchField(
                    key: const ValueKey('notes_search_field'),
                    controller: _searchController,
                    initiallyExpanded: true,
                    hintText: l10n?.searchNotesPlaceholder ?? 'Filter notes by title or content...',
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                    onCancelled: () {
                      setState(() {
                        _isSearchOpen = false;
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  ),
                ),
              ),

            // 2. Main Content
            notesAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: PoswalColors.teal)),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text('Error loading notes: $err', style: TextStyle(color: textMuted))),
              ),
              data: (allNotes) {
                // Collect distinct tags for filter row
                final tagsSet = <String>{};
                for (final n in allNotes) {
                  tagsSet.addAll(n.tags);
                }

                // Apply local search filtering if text entered
                final filtered = allNotes.where((note) {
                  if (_searchQuery.isEmpty) return true;
                  return note.title.toLowerCase().contains(_searchQuery) ||
                      note.body.toLowerCase().contains(_searchQuery) ||
                      note.tags.any((t) => t.toLowerCase().contains(_searchQuery));
                }).toList();

                if (allNotes.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIconsRegular.notepad, size: 56, color: textMuted.withValues(alpha: 0.5)),
                          const SizedBox(height: PoswalSpacing.md),
                          Text(
                            l10n?.noNotesYet ?? 'No notes yet',
                            style: PoswalText.title.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: PoswalSpacing.xs),
                          Text(
                            l10n?.noNotesYetSubtitle ?? 'Capture your thoughts, ideas, or start today\'s journal.',
                            style: PoswalText.caption.copyWith(color: textMuted),
                          ),
                          const SizedBox(height: PoswalSpacing.lg),
                          AppGlassButton(
                            key: const ValueKey('empty_new_note_btn'),
                            isPrimary: true,
                            onPressed: () => NoteEditorScreen.push(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(PhosphorIconsRegular.plus, size: 16),
                                const SizedBox(width: 6),
                                Text(l10n?.newNote ?? 'New Note'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final pinnedNotes = filtered.where((n) => n.isPinned).toList();
                final unpinnedNotes = filtered.where((n) => !n.isPinned).toList();

                return SliverPadding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: PoswalSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Horizontal Tag Filter Chips
                      if (tagsSet.isNotEmpty)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(bottom: PoswalSpacing.md),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                AppGlassChip(
                                  label: l10n?.allFilter ?? 'All',
                                  isSelected: selectedTag == null,
                                  onTap: () {
                                    ref.read(noteFilterTagProvider.notifier).setTag(null);
                                  },
                                ),
                                const SizedBox(width: PoswalSpacing.xs),
                                ...tagsSet.map((tag) {
                                  final isSelected = selectedTag == tag;
                                  return Padding(
                                    padding: const EdgeInsetsDirectional.only(end: PoswalSpacing.xs),
                                    child: AppGlassChip(
                                      label: '#$tag',
                                      isSelected: isSelected,
                                      onTap: () {
                                        ref.read(noteFilterTagProvider.notifier).setTag(isSelected ? null : tag);
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                      // Pinned Section (if any)
                      if (pinnedNotes.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(PhosphorIconsFill.pushPin, size: 14, color: PoswalColors.gold),
                            const SizedBox(width: 6),
                            Text(
                              'Pinned (${pinnedNotes.length})',
                              style: PoswalText.caption.copyWith(
                                color: PoswalColors.gold,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: PoswalSpacing.sm),
                        ...pinnedNotes.map((note) => Padding(
                              padding: const EdgeInsetsDirectional.only(bottom: PoswalSpacing.sm),
                              child: NoteCard(
                                key: ValueKey('note_card_${note.id}'),
                                note: note,
                                onTap: () => NoteEditorScreen.push(context, initialNote: note),
                                onLongPress: () => _openNoteActions(context, note),
                                onToggleChecklist: (lineIdx) {
                                  ref.read(noteRepositoryProvider).toggleChecklist(note.id, lineIdx);
                                },
                              ),
                            )),
                        const SizedBox(height: PoswalSpacing.md),
                      ],

                      // Unpinned Notes Section
                      if (unpinnedNotes.isNotEmpty) ...[
                        if (pinnedNotes.isNotEmpty)
                          Text(
                            'Other notes (${unpinnedNotes.length})',
                            style: PoswalText.caption.copyWith(
                              color: textMuted,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        if (pinnedNotes.isNotEmpty) const SizedBox(height: PoswalSpacing.sm),
                        ...unpinnedNotes.map((note) => Padding(
                              padding: const EdgeInsetsDirectional.only(bottom: PoswalSpacing.sm),
                              child: NoteCard(
                                key: ValueKey('note_card_${note.id}'),
                                note: note,
                                onTap: () => NoteEditorScreen.push(context, initialNote: note),
                                onLongPress: () => _openNoteActions(context, note),
                                onToggleChecklist: (lineIdx) {
                                  ref.read(noteRepositoryProvider).toggleChecklist(note.id, lineIdx);
                                },
                              ),
                            )),
                      ],

                      const SizedBox(height: 120), // Bottom space for tab bar & FAB
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
