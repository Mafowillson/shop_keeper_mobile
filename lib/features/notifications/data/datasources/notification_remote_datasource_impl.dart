import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/notifications/data/datasources/i_notification_remote_datasource.dart';
import 'package:shopkeeper/features/notifications/data/models/notification_model.dart';

@LazySingleton(as: INotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl
    implements INotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl(DioClient dioClient)
      : _dio = dioClient.client;

  @override
  Future<List<NotificationModel>> getNotifications(
      {bool isStaff = false, String? shopId}) async {
    try {
      final endpoint = isStaff ? '/staff/notifications' : '/notifications';
      final res = await _dio.get(
        endpoint,
        queryParameters: {
          if (!isStaff && shopId != null && shopId.isNotEmpty)
            'shop_id': shopId,
        },
      );
      final list = res.data['notifications'] as List<dynamic>? ?? [];
      return list
          .cast<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<void> markAsRead(String id, {bool isStaff = false}) async {
    try {
      final base = isStaff ? '/staff/notifications' : '/notifications';
      await _dio.patch('$base/$id/read');
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<void> markAllAsRead({bool isStaff = false, String? shopId}) async {
    try {
      final base = isStaff ? '/staff/notifications' : '/notifications';
      await _dio.patch(
        '$base/read-all',
        queryParameters: {
          if (!isStaff && shopId != null && shopId.isNotEmpty)
            'shop_id': shopId,
        },
      );
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
