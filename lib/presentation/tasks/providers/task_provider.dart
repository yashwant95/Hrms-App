import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:mobile/domain/entities/task.dart';
import 'package:mobile/data/repositories/task_repository.dart';
import 'package:mobile/data/datasources/task_remote_data_source.dart';
import 'package:mobile/core/utils/api_client.dart';
import 'package:mobile/presentation/auth/providers/auth_provider.dart';

// Providers
final taskRemoteDataSourceProvider = Provider((ref) => TaskRemoteDataSource(ref.read(apiClientProvider)));
final taskRepositoryProvider = Provider((ref) => TaskRepository(ref.read(taskRemoteDataSourceProvider)));

// State
class TaskState {
  final bool isLoading;
  final String? error;
  final List<Task> tasks;

  const TaskState({
    this.isLoading = false,
    this.error,
    this.tasks = const [],
  });

  TaskState copyWith({
    bool? isLoading,
    String? error,
    List<Task>? tasks,
  }) {
    return TaskState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tasks: tasks ?? this.tasks,
    );
  }
}

// Notifier
class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;

  TaskNotifier(this._repository) : super(const TaskState()) {
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getMyTasks();
    result.fold(
      (error) => state = state.copyWith(isLoading: false, error: error),
      (tasks) => state = state.copyWith(isLoading: false, tasks: tasks),
    );
  }

  Future<void> updateStatus(String id, String status) async {
    final result = await _repository.updateTaskStatus(id, status);
    result.fold(
      (error) => state = state.copyWith(error: error),
      (_) {
        // Optimistic update
        final updatedTasks = state.tasks.map((task) {
          if (task.id == id) {
            // Need to implement copyWith on Task entity or create new instance
             return Task(
               id: task.id, 
               title: task.title, 
               description: task.description, 
               status: status, 
               priority: task.priority,
               dueDate: task.dueDate
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
