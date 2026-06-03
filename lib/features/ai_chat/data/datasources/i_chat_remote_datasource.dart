import 'package:shopkeeper/features/ai_chat/data/models/chat_message_model.dart';

abstract class IChatRemoteDataSource {
  Future<String> sendMessage(String message);
  Future<List<ChatMessageModel>> loadHistory();
  Future<void> clearHistory();
}
