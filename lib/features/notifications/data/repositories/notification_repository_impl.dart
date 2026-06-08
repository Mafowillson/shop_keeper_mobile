import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/notifications/data/datasources/i_notification_remote_datasource.dart';
import 'package:shopkeeper/features/notifications/domain/entities/app_notification.dart';
import 'package:shopkeeper/features/notifications/domain/repositories/i_notification_repository.dart';

@LazySingleton(as: INotificationRepository)
class NotificationRepositoryImpl implements INotificationRepository {
  final INotificationRemoteDataSource _remote;

  NotificationRepositoryImpl(this._remote);

  @override
  TaskEither<Failure, List<AppNotification>> getNotifications(
          {bool isStaff = false, String? shopId}) =>
      TaskEither.tryCatch(
        () async {
          final models =
              await _remote.getNotifications(isStaff: isStaff, shopId: shopId);
          return models.map((m) => m.toEntity()).toList();
        },
        (e, _) => ServerFailure(e.toString()),
      );

  @override
  TaskEither<Failure, Unit> markAsRead(String id, {bool isStaff = false}) =>
      TaskEither.tryCatch(
        () async {
          await _remote.markAsRead(id, isStaff: isStaff);
          return unit;
        },
        (e, _) => ServerFailure(e.toString()),
      );

  @override
  TaskEither<Failure, Unit> markAllAsRead(
          {bool isStaff = false, String? shopId}) =>
      TaskEither.tryCatch(
        () async {
          await _remote.markAllAsRead(isStaff: isStaff, shopId: shopId);
          return unit;
        },
        (e, _) => ServerFailure(e.toString()),
      );
}
