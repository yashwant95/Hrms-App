import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class TaskRemoteDataSource {
  final ApiClient _apiClient;

  TaskRemoteDataSource(this._apiClient);

  Future<List<dynamic>> getMyTasks({
    String? category,
    String? priority,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.isNotEmpty && category != 'ALL') {
        queryParams['category'] = category;
      }
      if (priority != null && priority.isNotEmpty) {
        queryParams['priority'] = priority;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.client.get(
        '/tasks/my-tasks',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch tasks');
    }
  }

  Future<dynamic> createTask(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.post('/tasks', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create task');
    }
  }

  Future<dynamic> toggleTask(String id) async {
    try {
      final response = await _apiClient.client.patch('/tasks/$id/toggle');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to toggle task');
    }
  }

  Future<dynamic> updateTask(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.put('/tasks/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update task');
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

  Future<dynamic> toggleSubtask(String id, String subtaskId) async {
    try {
      final response = await _apiClient.client.patch('/tasks/$id/subtasks/$subtaskId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to toggle subtask');
    }
  }

  Future<dynamic> deleteTask(String id) async {
    try {
      final response = await _apiClient.client.delete('/tasks/$id');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete task');
    }
  }
}
