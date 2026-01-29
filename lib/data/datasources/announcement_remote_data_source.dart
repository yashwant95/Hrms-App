import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class AnnouncementRemoteDataSource {
  final ApiClient _apiClient;

  AnnouncementRemoteDataSource(this._apiClient);

  Future<List<dynamic>> getAnnouncements() async {
    try {
      final response = await _apiClient.client.get('/announcements');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch announcements');
    }
  }
}
