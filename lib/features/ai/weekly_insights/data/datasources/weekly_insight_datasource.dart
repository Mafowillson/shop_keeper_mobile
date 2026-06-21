import 'package:dio/dio.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/ai/weekly_insights/data/models/weekly_insight_model.dart';

class WeeklyInsightDataSource {
  final Dio _dio;

  WeeklyInsightDataSource(DioClient dioClient) : _dio = dioClient.client;

  Future<List<WeeklyInsightModel>> fetch(String shopId,
      {int limit = 4}) async {
    try {
      final res = await _dio.get(
        '/ai/weekly-insights',
        queryParameters: {'shop_id': shopId, 'limit': limit},
      );
      final list = res.data['data'] as List<dynamic>? ?? [];
      return list
          .cast<Map<String, dynamic>>()
          .map(WeeklyInsightModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  String _errorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['error'] as String? ?? e.message ?? 'Request failed';
    }
    return e.message ?? 'Request failed';
  }
}
