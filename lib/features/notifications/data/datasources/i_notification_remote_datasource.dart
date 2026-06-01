import 'package:shopkeeper/features/notifications/data/models/notification_model.dart';

abstract class INotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
