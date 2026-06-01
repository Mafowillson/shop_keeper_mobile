import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/staff/data/models/staff_dashboard_stats_model.dart';

abstract class IStaffDashboardDataSource {
  Future<StaffDashboardStatsModel> getStats();
}

@LazySingleton(as: IStaffDashboardDataSource)
class StaffDashboardDataSourceImpl implements IStaffDashboardDataSource {
  final Dio _dio;

  StaffDashboardDataSourceImpl(DioClient dioClient) : _dio = dioClient.client;

  @override
  Future<StaffDashboardStatsModel> getStats() async {
    try {
      final res = await _dio.get('/staff/dashboard');
      return StaffDashboardStatsModel.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg =
          (d is Map ? d['error'] as String? : null) ?? e.message ?? 'Request failed';
      throw Exception(msg);
    }
  }
}
