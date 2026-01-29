import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class TaskRemoteDataSource {
  final ApiClient _apiClient;

  TaskRemoteDataSource(this._apiClient);

  Future<List<dynamic>> getMyTasks() async {
    try {
      final response = await _apiClient.client.get('/tasks/my-tasks');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch tasks');
    }
  }

  Future<dynamic> updateTaskStatus(String id, String status) async {
    try {
      final response = await _apiClient.client.patch('/tasks/$id/status', data: {'status': status});
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update task');
    }
  }
}
