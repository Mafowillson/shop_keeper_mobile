import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/notifications/domain/entities/app_notification.dart';
import 'package:shopkeeper/features/notifications/domain/repositories/i_notification_repository.dart';

@lazySingleton
class GetNotificationsUseCase {
  final INotificationRepository _repository;

  const GetNotificationsUseCase(this._repository);

  TaskEither<Failure, List<AppNotification>> call({bool isStaff = false}) =>
      _repository.getNotifications(isStaff: isStaff);
}
