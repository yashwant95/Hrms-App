import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';
import '../../domain/entities/task.dart';
import 'providers/task_provider.dart';
import 'widgets/daily_progress_header.dart';
import 'widgets/task_filter_chips.dart';
import 'widgets/task_card.dart';
import 'widgets/quick_add_task_sheet.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  bool _isCompletedExpanded = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickAddTaskSheet(
        onAdd:
            ({
              required String title,
              String? description,
              String priority = 'MEDIUM',
              String category = 'WORK',
              DateTime? dueDate,
              List<String> subtaskTitles = const [],
            }) {
              ref
                  .read(taskProvider.notifier)
                  .createTask(
                    title: title,
                    description: description,
                    priority: priority,
                    category: category,
                    dueDate: dueDate,
                    subtaskTitles: subtaskTitles,
                  );
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskProvider);
    final notifier = ref.read(taskProvider.notifier);

    final filteredList = state.filteredTasks;

    // Split tasks for structured visual agenda if not filtering specifically by 'COMPLETED'
    final overdueTasks = filteredList.where((t) => t.isOverdue).toList();
    final todayTasks = filteredList
        .where((t) => t.isDueToday && !t.isCompleted)
        .toList();
    final upcomingTasks = filteredList
        .where((t) => t.isUpcoming && !t.isCompleted)
        .toList();
    final otherTasks = filteredList
        .where(
          (t) =>
              !t.isCompleted && !t.isDueToday && !t.isOverdue && !t.isUpcoming,
        )
        .toList();
    final completedTasks = filteredList.where((t) => t.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: appText(context, 'Search tasks', 'काम खोजें'),
                  border: InputBorder.none,
                ),
                onChanged: (q) => notifier.setSearchQuery(q),
              )
            : Text(
                appText(context, 'My tasks', 'मेरे काम'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  notifier.setSearchQuery('');
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.fetchTasks(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTaskModal,
        backgroundColor: AppTheme.primary,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: Text(
          appText(context, 'Add a task', 'काम जोड़ें'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.fetchTasks(),
        color: AppTheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // 1. Daily Progress Header
            SliverToBoxAdapter(
              child: DailyProgressHeader(
                totalCount: state.totalCount,
                completedCount: state.completedCount,
                overdueCount: state.overdueCount,
                progress: state.progressPercentage,
              ),
            ),

            // 2. Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: TaskFilterChips(
                  activeFilter: state.activeFilter,
                  onFilterSelected: (filter) => notifier.setFilter(filter),
                  state: state,
                ),
              ),
            ),

            // 3. Loading Indicator
            if (state.isLoading && state.tasks.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            // 4. Empty State
            else if (filteredList.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 56,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          appText(
                            context,
                            'No tasks here',
                            'यहाँ कोई काम नहीं है',
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.activeFilter == 'COMPLETED'
                              ? appText(
                                  context,
                                  'Completed tasks appear here.',
                                  'पूरे हुए काम यहाँ दिखेंगे।',
                                )
                              : appText(
                                  context,
                                  'You are all caught up. Add a task when you need one.',
                                  'अभी कोई काम बाकी नहीं है। ज़रूरत हो तो नया काम जोड़ें।',
                                ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            // 5. Categorized / Grouped Task Lists
            else ...[
              // Overdue Group (if active filter is not 'COMPLETED')
              if (state.activeFilter != 'COMPLETED' &&
                  overdueTasks.isNotEmpty) ...[
                _buildSectionHeader(
                  title: 'OVERDUE',
                  count: overdueTasks.length,
                  color: AppTheme.danger,
                  icon: Icons.warning_amber_rounded,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildCard(overdueTasks[index]),
                    childCount: overdueTasks.length,
                  ),
                ),
              ],

              // Today Group
              if (state.activeFilter != 'COMPLETED' &&
                  todayTasks.isNotEmpty) ...[
                _buildSectionHeader(
                  title: 'TODAY',
                  count: todayTasks.length,
                  color: Colors.amber[900]!,
                  icon: Icons.bolt_rounded,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildCard(todayTasks[index]),
                    childCount: todayTasks.length,
                  ),
                ),
              ],

              // Upcoming Group
              if (state.activeFilter != 'COMPLETED' &&
                  upcomingTasks.isNotEmpty) ...[
                _buildSectionHeader(
                  title: 'UPCOMING',
                  count: upcomingTasks.length,
                  color: AppTheme.primary,
                  icon: Icons.upcoming_rounded,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildCard(upcomingTasks[index]),
                    childCount: upcomingTasks.length,
                  ),
                ),
              ],

              // Other / No Date Group
              if (state.activeFilter != 'COMPLETED' &&
                  otherTasks.isNotEmpty) ...[
                _buildSectionHeader(
                  title: 'GENERAL TASKS',
                  count: otherTasks.length,
                  color: Colors.grey[700]!,
                  icon: Icons.format_list_bulleted_rounded,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildCard(otherTasks[index]),
                    childCount: otherTasks.length,
                  ),
                ),
              ],

              // Completed Group (Collapsible)
              if (completedTasks.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: InkWell(
                    onTap: () => setState(
                      () => _isCompletedExpanded = !_isCompletedExpanded,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: AppTheme.success,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'COMPLETED (${completedTasks.length})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppTheme.success,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _isCompletedExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isCompletedExpanded)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCard(completedTasks[index]),
                      childCount: completedTasks.length,
                    ),
                  ),
              ],

              // Bottom padding for FAB clearance
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Task task) {
    final notifier = ref.read(taskProvider.notifier);

    return TaskCard(
      task: task,
      onToggle: () => notifier.toggleTask(task.id),
      onDelete: () {
        notifier.deleteTask(task.id);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${task.title}"'),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.amber,
              onPressed: () => notifier.undoDelete(),
            ),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      onToggleSubtask: (subtaskId) =>
          notifier.toggleSubtask(task.id, subtaskId),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 6),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              '$title ($count)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
