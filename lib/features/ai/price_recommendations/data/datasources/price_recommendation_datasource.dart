import 'package:dio/dio.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/ai/price_recommendations/data/models/price_recommendation_model.dart';

class PriceRecommendationDataSource {
  final Dio _dio;

  PriceRecommendationDataSource(DioClient dioClient) : _dio = dioClient.client;

  Future<List<PriceRecommendationModel>> fetchPending(String shopId) async {
    try {
      final res = await _dio.get(
        '/ai/price-recommendations',
        queryParameters: {'shop_id': shopId, 'status': 'pending'},
      );
      final list = res.data['data'] as List<dynamic>? ?? [];
      return list
          .cast<Map<String, dynamic>>()
          .map(PriceRecommendationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<void> accept(String id) async {
    try {
      await _dio.post('/ai/price-recommendations/$id/accept');
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<void> dismiss(String id) async {
    try {
      await _dio.post('/ai/price-recommendations/$id/dismiss');
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
