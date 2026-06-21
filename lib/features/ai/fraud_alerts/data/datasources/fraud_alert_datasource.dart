import 'package:dio/dio.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/ai/fraud_alerts/data/models/fraud_alert_model.dart';

class FraudAlertDataSource {
  final Dio _dio;

  FraudAlertDataSource(DioClient dioClient) : _dio = dioClient.client;

  Future<List<FraudAlertModel>> fetchOpen(String shopId) async {
    try {
      final res = await _dio.get(
        '/ai/fraud-alerts',
        queryParameters: {'shop_id': shopId, 'status': 'open'},
      );
      final list = res.data['data'] as List<dynamic>? ?? [];
      return list
          .cast<Map<String, dynamic>>()
          .map(FraudAlertModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<List<FraudAlertModel>> fetchAll(String shopId) async {
    try {
      final res = await _dio.get(
        '/ai/fraud-alerts',
        queryParameters: {'shop_id': shopId},
      );
      final list = res.data['data'] as List<dynamic>? ?? [];
      return list
          .cast<Map<String, dynamic>>()
          .map(FraudAlertModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<void> acknowledge(String id) async {
    try {
      await _dio.patch('/ai/fraud-alerts/$id/acknowledge');
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
