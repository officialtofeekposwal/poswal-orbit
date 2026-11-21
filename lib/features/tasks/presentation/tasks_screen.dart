import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';
import 'package:poswal_orbit/features/tasks/application/task_providers.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_quick_add_sheet.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_row_card.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openQuickAdd() {
    TaskQuickAddSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    final selectedFilter = ref.watch(selectedTaskFilterProvider);
    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    final projectsAsync = ref.watch(projectsStreamProvider);

    // Select the active task stream based on the segmented control filter
    final AsyncValue<List<Task>> tasksAsync;
    switch (selectedFilter) {
      case TaskSmartFilter.today:
        tasksAsync = ref.watch(todayTasksStreamProvider);
        break;
      case TaskSmartFilter.upcoming:
        tasksAsync = ref.watch(upcomingTasksStreamProvider);
        break;
      case TaskSmartFilter.completed:
        tasksAsync = ref.watch(completedTasksStreamProvider);
        break;
      case TaskSmartFilter.all:
      default:
        tasksAsync = ref.watch(allTasksStreamProvider);
        break;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. App Bar Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PoswalSpacing.lg,
                vertical: PoswalSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasks',
                        style: PoswalText.largeTitle.copyWith(
                          fontSize: 26,
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Keep your day in motion',
                        style: PoswalText.caption.copyWith(color: textMuted),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isSearchExpanded ? PhosphorIconsRegular.x : PhosphorIconsRegular.magnifyingGlass,
                          color: textPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearchExpanded = !_isSearchExpanded;
                            if (!_isSearchExpanded) {
                              _searchController.clear();
                              ref.read(taskSearchQueryProvider.notifier).setQuery('');
                            }
                          });
                        },
                      ),
                      const SizedBox(width: PoswalSpacing.xs),
                      AppGlassButton(
                        isPrimary: true,
                        padding: const EdgeInsets.all(PoswalSpacing.sm),
                        onPressed: _openQuickAdd,
                        child: const Icon(PhosphorIconsBold.plus, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Search Bar (Expandable)
            if (_isSearchExpanded) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
                child: AppGlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md),
                  child: TextField(
                    controller: _searchController,
                    style: PoswalText.callout.copyWith(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: PoswalText.callout.copyWith(color: textMuted),
                      border: InputBorder.none,
                      icon: const Icon(PhosphorIconsRegular.magnifyingGlass, size: 18),
                    ),
                    onChanged: (val) {
                      ref.read(taskSearchQueryProvider.notifier).setQuery(val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: PoswalSpacing.sm),
            ],

            // 3. Glass Segmented Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
              child: AppGlassSegmentedControl<TaskSmartFilter>(
                values: const [
                  TaskSmartFilter.today,
                  TaskSmartFilter.upcoming,
                  TaskSmartFilter.all,
                  TaskSmartFilter.completed,
                ],
                labels: const ['Today', 'Upcoming', 'All', 'Done'],
                selectedValue: selectedFilter,
                onValueChanged: (val) {
                  ref.read(selectedTaskFilterProvider.notifier).setFilter(val);
                },
              ),
            ),
            const SizedBox(height: PoswalSpacing.sm),

            // 4. Project Filter Chips (Horizontal)
            projectsAsync.maybeWhen(
              data: (projects) {
                if (projects.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: PoswalSpacing.xs),
                        child: ChoiceChip(
                          label: const Text('All Projects'),
                          selected: selectedProjectId == null,
                          onSelected: (val) {
                            if (val) ref.read(selectedProjectIdProvider.notifier).select(null);
                          },
                        ),
                      ),
                      for (final proj in projects) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: PoswalSpacing.xs),
                          child: ChoiceChip(
                            label: Text(proj.name),
                            selected: selectedProjectId == proj.id,
                            onSelected: (val) {
                              ref.read(selectedProjectIdProvider.notifier).select(val ? proj.id : null);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: PoswalSpacing.xs),

            // 5. Tasks List
            Expanded(
              child: tasksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: PoswalColors.teal)),
                error: (err, _) => Center(
                  child: Text('Error loading tasks: $err', style: const TextStyle(color: PoswalColors.danger)),
                ),
                data: (tasks) {
                  // Filter by project and search if active
                  final searchQuery = ref.watch(taskSearchQueryProvider).toLowerCase().trim();
                  var filtered = tasks;

                  if (selectedProjectId != null) {
                    filtered = filtered.where((t) => t.projectId == selectedProjectId).toList();
                  }

                  if (searchQuery.isNotEmpty) {
                    filtered = filtered.where((t) =>
                      t.title.toLowerCase().contains(searchQuery) ||
                      (t.notes != null && t.notes!.toLowerCase().contains(searchQuery))
                    ).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(PoswalSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: PoswalColors.teal.withValues(alpha: 0.15),
                              ),
                              child: const Icon(PhosphorIconsRegular.sparkle, size: 28, color: PoswalColors.teal),
                            ),
                            const SizedBox(height: PoswalSpacing.md),
                            Text(
                              'All clear. Enjoy the quiet.',
                              style: PoswalText.headline.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: PoswalSpacing.xs),
                            Text(
                              'No pending tasks found for this view.',
                              textAlign: TextAlign.center,
                              style: PoswalText.callout.copyWith(color: textMuted),
                            ),
                            const SizedBox(height: PoswalSpacing.lg),
                            AppGlassButton(
                              isPrimary: true,
                              onPressed: _openQuickAdd,
                              child: const Text('Add Task'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ReorderableListView.builder(
                    padding: const EdgeInsets.only(
                      left: PoswalSpacing.lg,
                      right: PoswalSpacing.lg,
                      top: PoswalSpacing.xs,
                      bottom: 100,
                    ),
                    itemCount: filtered.length,
                    onReorder: (oldIndex, newIndex) async {
                      await HapticFeedback.selectionClick();
                      if (oldIndex < newIndex) newIndex -= 1;
                      final list = List<Task>.from(filtered);
                      final moved = list.removeAt(oldIndex);
                      list.insert(newIndex, moved);

                      final repo = ref.read(taskRepositoryProvider);
                      await repo.reorderTasks(list.map((t) => t.id).toList());
                    },
                    itemBuilder: (context, index) {
                      final task = filtered[index];
                      return TaskRowCard(
                        key: ValueKey('task_card_${task.id}'),
                        task: task,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
