import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/notifications/domain/repositories/i_notification_repository.dart';

@lazySingleton
class MarkAllReadUseCase {
  final INotificationRepository _repository;

  const MarkAllReadUseCase(this._repository);

  TaskEither<Failure, Unit> call({bool isStaff = false, String? shopId}) =>
      _repository.markAllAsRead(isStaff: isStaff, shopId: shopId);
}
