import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/dashboard/data/datasources/i_dashboard_datasource.dart';
import 'package:shopkeeper/features/dashboard/data/models/dashboard_stats_model.dart';

@LazySingleton(as: IDashboardRemoteDataSource)
class DashboardRemoteDataSourceImpl implements IDashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSourceImpl(DioClient dioClient) : _dio = dioClient.client;

  @override
  Future<DashboardStatsModel> getStats() async {
    try {
      final res = await _dio.get('/dashboard');
      return DashboardStatsModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg = (d is Map ? d['error'] as String? : null) ?? e.message ?? 'Request failed';
      throw Exception(msg);
    }
  }
}
