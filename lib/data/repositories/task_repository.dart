import 'package:dartz/dartz.dart' hide Task;
import '../../domain/entities/task.dart';
import '../datasources/task_remote_data_source.dart';

class TaskRepository {
  final TaskRemoteDataSource _dataSource;

  TaskRepository(this._dataSource);

  Future<Either<String, List<Task>>> getMyTasks() async {
    try {
      final data = await _dataSource.getMyTasks();
      final tasks = data.map((e) => Task.fromJson(e)).toList();
      return Right(tasks);
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
}
