import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/notifications/domain/entities/app_notification.dart';

abstract class INotificationRepository {
  TaskEither<Failure, List<AppNotification>> getNotifications({bool isStaff = false});
  TaskEither<Failure, Unit> markAsRead(String id, {bool isStaff = false});
  TaskEither<Failure, Unit> markAllAsRead({bool isStaff = false});
}
