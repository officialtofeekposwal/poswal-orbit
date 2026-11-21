import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/domain/models/search_models.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_detail_screen.dart';
import 'package:poswal_orbit/features/notes/presentation/note_editor_screen.dart';
import 'package:poswal_orbit/features/search/application/search_providers.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_detail_sheet.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
    );
  }

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTap(SearchResultItem item) {
    HapticFeedback.selectionClick();
    switch (item.type) {
      case SearchResultType.habit:
        if (item.habit != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HabitDetailScreen(habitId: item.habit!.id),
            ),
          );
        }
        break;
      case SearchResultType.task:
        if (item.task != null) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => TaskDetailSheet(task: item.task!),
          );
        }
        break;
      case SearchResultType.note:
        if (item.note != null) {
          NoteEditorScreen.push(context, initialNote: item.note!);
        }
        break;
    }
  }

  Widget _buildResultItem(SearchResultItem item, bool isDark) {
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;
    final cardBg = isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: PoswalSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(PoswalRadii.card),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(PoswalRadii.card),
            onTap: () => _onItemTap(item),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(PoswalSpacing.md),
              child: Row(
                children: [
                  // Leading Type Icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: item.colorValue != null && item.colorValue! != 0
                          ? Color(item.colorValue!).withValues(alpha: 0.18)
                          : PoswalColors.teal.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.type == SearchResultType.habit
                          ? PhosphorIconsRegular.sparkle
                          : (item.type == SearchResultType.task
                              ? PhosphorIconsRegular.checkSquare
                              : PhosphorIconsRegular.note),
                      size: 18,
                      color: item.colorValue != null && item.colorValue! != 0
                          ? Color(item.colorValue!)
                          : PoswalColors.teal,
                    ),
                  ),

                  const SizedBox(width: PoswalSpacing.md),

                  // Title & Snippet
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PoswalText.headline.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.snippet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PoswalText.caption.copyWith(color: textMuted),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 16,
                    color: Colors.white30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    final resultsAsync = ref.watch(globalSearchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Search Bar Top Header
              Padding(
                padding: const EdgeInsetsDirectional.all(PoswalSpacing.md),
                child: Row(
                  children: [
                    IconButton(
                      key: const ValueKey('search_back_btn'),
                      icon: const Icon(PhosphorIconsRegular.caretLeft, size: 24),
                      color: textPrimary,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: PoswalSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight,
                          borderRadius: BorderRadius.circular(PoswalRadii.button),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: TextField(
                          key: const ValueKey('global_search_input'),
                          controller: _controller,
                          autofocus: true,
                          style: TextStyle(color: textPrimary),
                          decoration: InputDecoration(
                            icon: Icon(PhosphorIconsRegular.magnifyingGlass, color: textMuted, size: 20),
                            hintText: 'Search habits, tasks, notes...',
                            hintStyle: TextStyle(color: textMuted),
                            border: InputBorder.none,
                          ),
                          onChanged: (text) {
                            ref.read(searchQueryProvider.notifier).setQuery(text);
                          },
                        ),
                      ),
                    ),
                    if (query.isNotEmpty)
                      IconButton(
                        key: const ValueKey('search_clear_btn'),
                        icon: const Icon(PhosphorIconsRegular.xCircle, size: 22),
                        color: textMuted,
                        onPressed: () {
                          _controller.clear();
                          ref.read(searchQueryProvider.notifier).setQuery('');
                        },
                      ),
                  ],
                ),
              ),

              // 2. Results List
              Expanded(
                child: query.trim().isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.all(PoswalSpacing.xl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PhosphorIconsRegular.magnifyingGlass,
                                size: 52,
                                color: textMuted.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: PoswalSpacing.md),
                              Text(
                                'Global Search',
                                style: PoswalText.title.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: PoswalSpacing.xs),
                              Text(
                                'Search habits, tasks, markdown notes, tags and journal entries in one place.',
                                textAlign: TextAlign.center,
                                style: PoswalText.caption.copyWith(color: textMuted),
                              ),
                            ],
                          ),
                        ),
                      )
                    : resultsAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: PoswalColors.teal),
                        ),
                        error: (err, _) => Center(
                          child: Text('Search error: $err', style: TextStyle(color: textMuted)),
                        ),
                        data: (results) {
                          if (results.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    PhosphorIconsRegular.magnifyingGlass,
                                    size: 48,
                                    color: textMuted.withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(height: PoswalSpacing.md),
                                  Text(
                                    'No results for "$query"',
                                    style: PoswalText.headline.copyWith(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: PoswalSpacing.xs),
                                  Text(
                                    'Check your spelling or try broader terms.',
                                    style: PoswalText.caption.copyWith(color: textMuted),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsetsDirectional.all(PoswalSpacing.lg),
                            children: [
                              // 1. Habits Group
                              if (results.habits.isNotEmpty) ...[
                                Row(
                                  children: [
                                    const Icon(PhosphorIconsRegular.sparkle, size: 14, color: PoswalColors.teal),
                                    const SizedBox(width: 6),
                                    Text(
                                      'HABITS (${results.habits.length})',
                                      style: PoswalText.caption.copyWith(
                                        color: PoswalColors.teal,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: PoswalSpacing.sm),
                                ...results.habits.map((item) => _buildResultItem(item, isDark)),
                                const SizedBox(height: PoswalSpacing.md),
                              ],

                              // 2. Tasks Group
                              if (results.tasks.isNotEmpty) ...[
                                Row(
                                  children: [
                                    const Icon(PhosphorIconsRegular.checkSquare, size: 14, color: PoswalColors.coral),
                                    const SizedBox(width: 6),
                                    Text(
                                      'TASKS (${results.tasks.length})',
                                      style: PoswalText.caption.copyWith(
                                        color: PoswalColors.coral,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: PoswalSpacing.sm),
                                ...results.tasks.map((item) => _buildResultItem(item, isDark)),
                                const SizedBox(height: PoswalSpacing.md),
                              ],

                              // 3. Notes Group
                              if (results.notes.isNotEmpty) ...[
                                Row(
                                  children: [
                                    const Icon(PhosphorIconsRegular.note, size: 14, color: PoswalColors.violet),
                                    const SizedBox(width: 6),
                                    Text(
                                      'NOTES (${results.notes.length})',
                                      style: PoswalText.caption.copyWith(
                                        color: PoswalColors.violet,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: PoswalSpacing.sm),
                                ...results.notes.map((item) => _buildResultItem(item, isDark)),
                              ],
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
