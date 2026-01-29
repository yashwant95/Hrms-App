import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class AttendanceRemoteDataSource {
  final ApiClient _apiClient;

  AttendanceRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> checkIn(double lat, double long, String address) async {
    try {
      final response = await _apiClient.client.post('/attendance/check-in', data: {
        'latitude': lat,
        'longitude': long,
        'address': address,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Check-in failed');
    }
  }

  Future<Map<String, dynamic>> checkOut() async {
    try {
      final response = await _apiClient.client.post('/attendance/check-out');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Check-out failed');
    }
  }

  Future<Map<String, dynamic>> getTodayStatus() async {
    try {
      final response = await _apiClient.client.get('/attendance/today');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get status');
    }
  }
}
