import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/notifications/domain/repositories/i_notification_repository.dart';

@lazySingleton
class MarkReadUseCase {
  final INotificationRepository _repository;

  const MarkReadUseCase(this._repository);

  TaskEither<Failure, Unit> call(String id) => _repository.markAsRead(id);
}
