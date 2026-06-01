import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/notifications/data/datasources/i_notification_remote_datasource.dart';
import 'package:shopkeeper/features/notifications/data/models/notification_model.dart';

@LazySingleton(as: INotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements INotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl(DioClient dioClient) : _dio = dioClient.client;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final res = await _dio.get('/notifications');
      final list = res.data['notifications'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>().map(NotificationModel.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/notifications/read-all');
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  String _msg(DioException e) {
    final d = e.response?.data;
    if (d is Map) return d['error'] as String? ?? e.message ?? 'Request failed';
    return e.message ?? 'Request failed';
  }
}
