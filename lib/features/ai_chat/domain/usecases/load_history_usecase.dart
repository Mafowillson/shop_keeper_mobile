import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/ai_chat/domain/entities/chat_message.dart';
import 'package:shopkeeper/features/ai_chat/domain/repositories/i_chat_repository.dart';

@lazySingleton
class LoadHistoryUseCase {
  final IChatRepository _repository;

  const LoadHistoryUseCase(this._repository);

  TaskEither<Failure, List<ChatMessage>> call() => _repository.loadHistory();
}
