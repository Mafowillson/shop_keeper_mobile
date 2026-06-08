import 'package:shopkeeper/features/notifications/data/models/notification_model.dart';

abstract class INotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications(
      {bool isStaff = false, String? shopId});
  Future<void> markAsRead(String id, {bool isStaff = false});
  Future<void> markAllAsRead({bool isStaff = false, String? shopId});
}
