import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/ai_chat/domain/repositories/i_chat_repository.dart';

@lazySingleton
class SendMessageUseCase {
  final IChatRepository _repository;

  const SendMessageUseCase(this._repository);

  TaskEither<Failure, String> call(String msg) => _repository.sendMessage(msg);
}
