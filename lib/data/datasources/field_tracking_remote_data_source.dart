import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class FieldTrackingRemoteDataSource {
  final ApiClient _apiClient;

  FieldTrackingRemoteDataSource(this._apiClient);

  Future<dynamic> getDayTimeline({String? date, String? userId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) queryParams['date'] = date;
      if (userId != null) queryParams['userId'] = userId;

      final response = await _apiClient.client.get(
        '/field-tracking/timeline',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch field timeline');
    }
  }

  Future<dynamic> logClientVisit(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.post('/field-tracking/visit', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to log client visit');
    }
  }

  Future<dynamic> checkoutClientVisit(String visitId, {String? notes}) async {
    try {
      final response = await _apiClient.client.patch(
        '/field-tracking/visit/$visitId/checkout',
        data: {if (notes != null) 'notes': notes},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to checkout client visit');
    }
  }

  Future<dynamic> recordBreadcrumb(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.post('/field-tracking/ping', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to record location ping');
    }
  }
}
