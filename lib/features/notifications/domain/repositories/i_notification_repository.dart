import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/notifications/domain/entities/app_notification.dart';

abstract class INotificationRepository {
  TaskEither<Failure, List<AppNotification>> getNotifications();
  TaskEither<Failure, Unit> markAsRead(String id);
  TaskEither<Failure, Unit> markAllAsRead();
}
