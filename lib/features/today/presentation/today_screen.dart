import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/app_list_section.dart';
import 'package:poswal_orbit/core/widgets/app_search_field.dart';
import 'package:poswal_orbit/core/widgets/app_toolbar.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/search_models.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_detail_screen.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_form_sheet.dart';
import 'package:poswal_orbit/features/notes/presentation/note_editor_screen.dart';
import 'package:poswal_orbit/features/search/application/search_providers.dart';
import 'package:poswal_orbit/features/settings/presentation/settings_screen.dart';
import 'package:poswal_orbit/features/tasks/application/task_providers.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_row_card.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';
import 'package:poswal_orbit/features/today/presentation/widgets/habit_row_card.dart';
import 'package:poswal_orbit/features/today/presentation/widgets/hero_orbit_card.dart';
import 'package:poswal_orbit/features/today/presentation/widgets/week_strip.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting(AppLocalizations? l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n?.greetingMorning ?? 'Good morning';
    if (hour < 17) return l10n?.greetingAfternoon ?? 'Good afternoon';
    return l10n?.greetingEvening ?? 'Good evening';
  }

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HabitFormSheet(),
    );
  }

  void _openEditSheet(BuildContext context, Habit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HabitFormSheet(habitToEdit: habit),
    );
  }

  void _onSearchResultTap(SearchResultItem item) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;

    final selectedDate = ref.watch(selectedDateProvider);
    final todayAsync = ref.watch(todayHabitsDataProvider);
    final tasksAsync = ref.watch(todayTasksStreamProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final isSearching = searchQuery.trim().isNotEmpty;
    final formattedDate = DateFormat('EEEE, MMM d').format(selectedDate);

    return AuroraBackground(
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Bar with Safe Area Handling (AppToolbar + Inline Search)
            SliverToBoxAdapter(
              child: AppToolbar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(l10n),
                      style: PoswalText.title.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: PoswalText.caption.copyWith(color: textMuted),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    key: const ValueKey('global_search_btn'),
                    icon: Icon(
                      _isSearchExpanded ? PhosphorIconsRegular.x : PhosphorIconsRegular.magnifyingGlass,
                      size: 20,
                    ),
                    color: textPrimary,
                    tooltip: l10n?.searchTooltip ?? 'Search',
                    onPressed: () {
                      setState(() {
                        _isSearchExpanded = !_isSearchExpanded;
                        if (!_isSearchExpanded) {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).setQuery('');
                        }
                      });
                    },
                  ),
                  IconButton(
                    key: const ValueKey('settings_btn'),
                    icon: const Icon(PhosphorIconsRegular.gear, size: 20),
                    color: textPrimary,
                    tooltip: l10n?.settingsTooltip ?? 'Settings',
                    onPressed: () => SettingsScreen.push(context),
                  ),
                ],
                showAddButton: true,
                addTooltip: 'Create new item',
                addKey: const ValueKey('app_fab_button'),
                onAddPressed: () => _openCreateSheet(context),
              ),
            ),

            // Inline Expandable Search Field (HIG Search Pattern)
            if (_isSearchExpanded)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: PoswalSpacing.lg,
                    end: PoswalSpacing.lg,
                    bottom: PoswalSpacing.sm,
                  ),
                  child: AppSearchField(
                    controller: _searchController,
                    initiallyExpanded: true,
                    hintText: l10n?.searchTooltip ?? 'Search habits, tasks, notes...',
                    onChanged: (val) {
                      ref.read(searchQueryProvider.notifier).setQuery(val);
                    },
                    onCancelled: () {
                      setState(() {
                        _isSearchExpanded = false;
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).setQuery('');
                      });
                    },
                  ),
                ),
              ),

            // 2. Body: Either Search Results or Today Content Feed
            if (isSearching)
              ..._buildSearchResultsSlivers(isDark, textPrimary, textMuted)
            else ...[
              // Week Strip
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
                  child: WeekStrip(),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: PoswalSpacing.md),
              ),

              // 3. Hero Orbit Progress Ring Card
              todayAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(PoswalSpacing.xxl),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: PoswalColors.teal),
                    ),
                  ),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $err', style: PoswalText.caption)),
                ),
                data: (data) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        HeroOrbitCard(
                          totalDue: data.totalDue,
                          totalDone: data.totalDone,
                          completionRate: data.completionRate,
                        ),

                        const SizedBox(height: PoswalSpacing.lg),

                        // Empty State for Day
                        if (data.totalDue == 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.xl),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(PhosphorIconsRegular.calendarCheck, size: 48, color: textMuted),
                                  const SizedBox(height: PoswalSpacing.md),
                                  Text(
                                    l10n?.noHabitsScheduled ??
                                        'No habits scheduled for this day.\nRest and recharge, or create a new habit below.',
                                    textAlign: TextAlign.center,
                                    style: PoswalText.callout.copyWith(color: textMuted),
                                  ),
                                  const SizedBox(height: PoswalSpacing.lg),
                                  AppGlassButton(
                                    isPrimary: true,
                                    onPressed: () => _openCreateSheet(context),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(PhosphorIconsBold.plus, size: 16, color: Colors.white),
                                        const SizedBox(width: PoswalSpacing.xs),
                                        Text(l10n?.addHabit ?? 'Add Habit'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Grouped Habits in Inset Grouped AppListSection (HIG Rule 9: Title Case Headers)
                        if (data.allScheduled.isNotEmpty) ...[
                          for (final group in [
                            TimeOfDayGroup.morning,
                            TimeOfDayGroup.afternoon,
                            TimeOfDayGroup.evening,
                            TimeOfDayGroup.anytime,
                          ]) ...[
                            if (data.grouped[group]?.isNotEmpty ?? false) ...[
                              AppListSection(
                                title: _getGroupTitle(group),
                                headerTrailing: Text(
                                  '(${data.grouped[group]!.length})',
                                  style: PoswalText.caption.copyWith(color: textMuted),
                                ),
                                margin: const EdgeInsets.only(bottom: PoswalSpacing.md),
                                children: [
                                  for (final item in data.grouped[group]!)
                                    HabitRowCard(
                                      item: item,
                                      inGroupedSection: true,
                                      onEdit: () => _openEditSheet(context, item.habit),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ],

                        // 4. Tasks Due & Overdue Section in Inset Grouped AppListSection
                        tasksAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: PoswalSpacing.md),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: PoswalColors.teal),
                              ),
                            ),
                          ),
                          error: (err, _) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.sm),
                            child: Text(
                              'Unable to load tasks: $err',
                              style: PoswalText.caption.copyWith(color: PoswalColors.danger),
                            ),
                          ),
                          data: (tasks) {
                            final pending = tasks.where((t) => !t.isCompleted).length;
                            return AppListSection(
                              title: l10n?.tasksTitle ?? 'Tasks',
                              headerTrailing: pending > 0
                                  ? Text(
                                      l10n?.tasksDueCount(pending) ?? '($pending due)',
                                      style: PoswalText.caption.copyWith(color: textMuted),
                                    )
                                  : null,
                              margin: const EdgeInsets.only(bottom: PoswalSpacing.md),
                              children: tasks.isEmpty
                                  ? [
                                      Padding(
                                        padding: const EdgeInsets.all(PoswalSpacing.lg),
                                        child: Center(
                                          child: Text(
                                            l10n?.allClear ?? 'All clear. Enjoy the quiet.',
                                            style: PoswalText.callout.copyWith(
                                              color: textMuted,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]
                                  : [
                                      for (final task in tasks)
                                        TaskRowCard(task: task),
                                    ],
                            );
                          },
                        ),

                        const SizedBox(height: 100), // Space for floating bottom tab bar
                      ]),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSearchResultsSlivers(bool isDark, Color textPrimary, Color textMuted) {
    final searchAsync = ref.watch(globalSearchResultsProvider);
    final l10n = AppLocalizations.of(context);
    return [
      searchAsync.when(
        loading: () => const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(PoswalSpacing.xxl),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: PoswalColors.teal),
            ),
          ),
        ),
        error: (err, _) => SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(PoswalSpacing.lg),
            child: Center(
              child: Text('Search error: $err', style: PoswalText.caption.copyWith(color: PoswalColors.danger)),
            ),
          ),
        ),
        data: (results) {
          if (results.totalCount == 0) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(PoswalSpacing.xxl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(PhosphorIconsRegular.magnifyingGlass, size: 40, color: textMuted),
                      const SizedBox(height: PoswalSpacing.md),
                      Text(l10n?.noMatchingResults ?? 'No matching results found', style: PoswalText.callout.copyWith(color: textMuted)),
                    ],
                  ),
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (results.habits.isNotEmpty)
                  AppListSection(
                    title: l10n?.searchSectionHabits(results.habits.length) ?? 'Habits (${results.habits.length})',
                    margin: const EdgeInsets.only(bottom: PoswalSpacing.md),
                    children: results.habits.map((item) => _buildResultRow(item, isDark, textPrimary, textMuted)).toList(),
                  ),
                if (results.tasks.isNotEmpty)
                  AppListSection(
                    title: l10n?.searchSectionTasks(results.tasks.length) ?? 'Tasks (${results.tasks.length})',
                    margin: const EdgeInsets.only(bottom: PoswalSpacing.md),
                    children: results.tasks.map((item) => _buildResultRow(item, isDark, textPrimary, textMuted)).toList(),
                  ),
                if (results.notes.isNotEmpty)
                  AppListSection(
                    title: l10n?.searchSectionNotes(results.notes.length) ?? 'Notes (${results.notes.length})',
                    margin: const EdgeInsets.only(bottom: PoswalSpacing.md),
                    children: results.notes.map((item) => _buildResultRow(item, isDark, textPrimary, textMuted)).toList(),
                  ),
                const SizedBox(height: 100),
              ]),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildResultRow(SearchResultItem item, bool isDark, Color textPrimary, Color textMuted) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: item.colorValue != null && item.colorValue != 0
              ? Color(item.colorValue!).withValues(alpha: 0.15)
              : PoswalColors.teal.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          item.type == SearchResultType.habit
              ? PhosphorIconsRegular.sparkle
              : (item.type == SearchResultType.task
                  ? PhosphorIconsRegular.checkSquare
                  : PhosphorIconsRegular.note),
          size: 16,
          color: item.colorValue != null
              ? Color(item.colorValue!)
              : PoswalColors.teal,
        ),
      ),
      title: Text(item.title, style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
      subtitle: item.snippet.isNotEmpty
          ? Text(item.snippet, maxLines: 1, overflow: TextOverflow.ellipsis, style: PoswalText.caption.copyWith(color: textMuted))
          : null,
      onTap: () => _onSearchResultTap(item),
    );
  }

  String _getGroupTitle(TimeOfDayGroup group) {
    switch (group) {
      case TimeOfDayGroup.morning:
        return 'Morning Habits';
      case TimeOfDayGroup.afternoon:
        return 'Afternoon Habits';
      case TimeOfDayGroup.evening:
        return 'Evening Habits';
      case TimeOfDayGroup.anytime:
        return 'Anytime Habits';
    }
  }
}
