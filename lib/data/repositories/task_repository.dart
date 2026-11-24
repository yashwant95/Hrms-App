import 'package:dartz/dartz.dart' hide Task;
import '../../domain/entities/task.dart';
import '../datasources/task_remote_data_source.dart';

class TaskRepository {
  final TaskRemoteDataSource _dataSource;

  TaskRepository(this._dataSource);

  Future<Either<String, List<Task>>> getMyTasks({
    String? category,
    String? priority,
    String? status,
    String? search,
  }) async {
    try {
      final data = await _dataSource.getMyTasks(
        category: category,
        priority: priority,
        status: status,
        search: search,
      );
      final tasks = data.map((e) => Task.fromJson(e)).toList();
      return Right(tasks);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Either<String, Task>> createTask(Map<String, dynamic> data) async {
    try {
      final res = await _dataSource.createTask(data);
      return Right(Task.fromJson(res));
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Either<String, Task>> toggleTask(String id) async {
    try {
      final res = await _dataSource.toggleTask(id);
      return Right(Task.fromJson(res));
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Either<String, Task>> updateTask(String id, Map<String, dynamic> data) async {
    try {
      final res = await _dataSource.updateTask(id, data);
      return Right(Task.fromJson(res));
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Either<String, void>> updateTaskStatus(String id, String status) async {
    try {
      await _dataSource.updateTaskStatus(id, status);
      return const Right(null);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Either<String, Task>> toggleSubtask(String id, String subtaskId) async {
    try {
      final res = await _dataSource.toggleSubtask(id, subtaskId);
      return Right(Task.fromJson(res));
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Either<String, void>> deleteTask(String id) async {
    try {
      await _dataSource.deleteTask(id);
      return const Right(null);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
