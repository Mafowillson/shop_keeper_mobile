import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/ai_chat/domain/repositories/i_chat_repository.dart';

@lazySingleton
class ClearHistoryUseCase {
  final IChatRepository _repository;

  const ClearHistoryUseCase(this._repository);

  TaskEither<Failure, Unit> call() => _repository.clearHistory();
}
