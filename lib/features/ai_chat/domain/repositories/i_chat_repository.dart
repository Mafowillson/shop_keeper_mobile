import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/ai_chat/domain/entities/chat_message.dart';

abstract class IChatRepository {
  TaskEither<Failure, String> sendMessage(String msg, List<ChatMessage> history);
  TaskEither<Failure, List<ChatMessage>> loadHistory();
}
