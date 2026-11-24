import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/domain/entities/task.dart';
import 'package:mobile/data/repositories/task_repository.dart';
import 'package:mobile/data/datasources/task_remote_data_source.dart';
import 'package:mobile/presentation/auth/providers/auth_provider.dart';

// Providers
final taskRemoteDataSourceProvider = Provider((ref) => TaskRemoteDataSource(ref.read(apiClientProvider)));
final taskRepositoryProvider = Provider((ref) => TaskRepository(ref.read(taskRemoteDataSourceProvider)));

// State
class TaskState {
  final bool isLoading;
  final String? error;
  final List<Task> tasks;
  final String activeFilter; // 'ALL', 'TODAY', 'URGENT', 'WORK', 'PERSONAL', 'COMPLETED'
  final String searchQuery;

  const TaskState({
    this.isLoading = false,
    this.error,
    this.tasks = const [],
    this.activeFilter = 'ALL',
    this.searchQuery = '',
  });

  int get totalCount => tasks.length;
  int get completedCount => tasks.where((t) => t.isCompleted).length;

  int get todayTotalCount => tasks.where((t) => t.isDueToday || (t.isCompleted && t.isDueToday)).length;
  int get todayCompletedCount => tasks.where((t) => t.isCompleted && t.isDueToday).length;

  int get overdueCount => tasks.where((t) => t.isOverdue).length;

  double get progressPercentage {
    if (tasks.isEmpty) return 0.0;
    return (completedCount / totalCount).clamp(0.0, 1.0);
  }

  List<Task> get filteredTasks {
    return tasks.where((task) {
      // 1. Search Query filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(query);
        final matchesDesc = task.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc) return false;
      }

      // 2. Chip filter
      switch (activeFilter) {
        case 'TODAY':
          return task.isDueToday || task.isOverdue;
        case 'URGENT':
          return task.priority == 'HIGH';
        case 'WORK':
          return task.category == 'WORK' || task.category == 'HR_COMPLIANCE' || task.category == 'MEETING';
        case 'PERSONAL':
          return task.category == 'PERSONAL';
        case 'COMPLETED':
          return task.isCompleted;
        case 'ALL':
        default:
          return true;
      }
    }).toList();
  }

  TaskState copyWith({
    bool? isLoading,
    String? error,
    List<Task>? tasks,
    String? activeFilter,
    String? searchQuery,
  }) {
    return TaskState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tasks: tasks ?? this.tasks,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Notifier
class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;
  Task? _recentlyDeletedTask;
  int? _recentlyDeletedIndex;

  TaskNotifier(this._repository) : super(const TaskState()) {
    fetchTasks();
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> fetchTasks() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getMyTasks();
    result.fold(
      (error) => state = state.copyWith(isLoading: false, error: error),
      (tasks) => state = state.copyWith(isLoading: false, tasks: tasks),
    );
  }

  // 1-Tap Toggle Task Completion (Instant Optimistic UI)
  Future<void> toggleTask(String id) async {
    final previousTasks = List<Task>.from(state.tasks);

    // Apply immediate optimistic flip
    final updatedTasks = state.tasks.map((task) {
      if (task.id == id) {
        final newCompleted = !task.isCompleted;
        return task.copyWith(
          isCompleted: newCompleted,
          status: newCompleted ? 'COMPLETED' : 'TODO',
          completedAt: newCompleted ? DateTime.now() : null,
        );
      }
      return task;
    }).toList();

    state = state.copyWith(tasks: updatedTasks);

    // Background sync with API
    final result = await _repository.toggleTask(id);
    result.fold(
      (error) {
        // Rollback on network failure
        state = state.copyWith(tasks: previousTasks, error: error);
      },
      (syncedTask) {
        final finalTasks = state.tasks.map((t) => t.id == id ? syncedTask : t).toList();
        state = state.copyWith(tasks: finalTasks);
      },
    );
  }

  // Quick Add Task (Optimistic)
  Future<bool> createTask({
    required String title,
    String? description,
    String priority = 'MEDIUM',
    String category = 'WORK',
    DateTime? dueDate,
    List<String> subtaskTitles = const [],
  }) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempSubtasks = subtaskTitles
        .map((t) => SubTask(id: 'temp_sub_${DateTime.now().millisecondsSinceEpoch}_$t', title: t))
        .toList();

    final newTask = Task(
      id: tempId,
      title: title,
      description: description ?? '',
      status: 'TODO',
      priority: priority,
      category: category,
      dueDate: dueDate,
      isCompleted: false,
      subtasks: tempSubtasks,
    );

    // Optimistically insert at beginning
    state = state.copyWith(tasks: [newTask, ...state.tasks]);

    final payload = {
      'title': title,
      if (description != null && description.isNotEmpty) 'description': description,
      'priority': priority,
      'category': category,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      'subtasks': tempSubtasks.map((s) => s.toJson()).toList(),
    };

    final result = await _repository.createTask(payload);
    return result.fold(
      (error) {
        // Remove temp task on error
        state = state.copyWith(
          tasks: state.tasks.where((t) => t.id != tempId).toList(),
          error: error,
        );
        return false;
      },
      (persistedTask) {
        final syncedTasks = state.tasks.map((t) => t.id == tempId ? persistedTask : t).toList();
        state = state.copyWith(tasks: syncedTasks);
        return true;
      },
    );
  }

  // Toggle Subtask
  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    final previousTasks = List<Task>.from(state.tasks);

    final updatedTasks = state.tasks.map((task) {
      if (task.id == taskId) {
        final updatedSubtasks = task.subtasks.map((st) {
          if (st.id == subtaskId) {
            return st.copyWith(isCompleted: !st.isCompleted);
          }
          return st;
        }).toList();

        final allDone = updatedSubtasks.isNotEmpty && updatedSubtasks.every((s) => s.isCompleted);
        return task.copyWith(
          subtasks: updatedSubtasks,
          isCompleted: allDone ? true : task.isCompleted,
          status: allDone ? 'COMPLETED' : task.status,
        );
      }
      return task;
    }).toList();

    state = state.copyWith(tasks: updatedTasks);

    final result = await _repository.toggleSubtask(taskId, subtaskId);
    result.fold(
      (error) => state = state.copyWith(tasks: previousTasks, error: error),
      (syncedTask) {
        state = state.copyWith(
          tasks: state.tasks.map((t) => t.id == taskId ? syncedTask : t).toList(),
        );
      },
    );
  }

  // Delete Task with Undo Support
  Future<void> deleteTask(String id) async {
    final index = state.tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    _recentlyDeletedTask = state.tasks[index];
    _recentlyDeletedIndex = index;

    // Optimistic remove
    final updatedList = List<Task>.from(state.tasks)..removeAt(index);
    state = state.copyWith(tasks: updatedList);

    final result = await _repository.deleteTask(id);
    result.fold(
      (error) {
        // Rollback
        if (_recentlyDeletedTask != null && _recentlyDeletedIndex != null) {
          final restored = List<Task>.from(state.tasks);
          restored.insert(_recentlyDeletedIndex!, _recentlyDeletedTask!);
          state = state.copyWith(tasks: restored, error: error);
        }
      },
      (_) {},
    );
  }

  // Undo delete
  void undoDelete() {
    if (_recentlyDeletedTask != null && _recentlyDeletedIndex != null) {
      final restored = List<Task>.from(state.tasks);
      final insertIndex = _recentlyDeletedIndex!.clamp(0, restored.length);
      restored.insert(insertIndex, _recentlyDeletedTask!);
      state = state.copyWith(tasks: restored);

      // Re-create on server
      _repository.createTask(_recentlyDeletedTask!.toJson());
      _recentlyDeletedTask = null;
      _recentlyDeletedIndex = null;
    }
  }

  // Legacy update status support
  Future<void> updateStatus(String id, String status) async {
    final newCompleted = status == 'COMPLETED';
    final result = await _repository.updateTaskStatus(id, status);
    result.fold(
      (error) => state = state.copyWith(error: error),
      (_) {
        final updatedTasks = state.tasks.map((task) {
          if (task.id == id) {
            return task.copyWith(
              status: status,
              isCompleted: newCompleted,
              completedAt: newCompleted ? DateTime.now() : null,
            );
          }
          return task;
        }).toList();
        state = state.copyWith(tasks: updatedTasks);
      },
    );
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(ref.watch(taskRepositoryProvider));
});
