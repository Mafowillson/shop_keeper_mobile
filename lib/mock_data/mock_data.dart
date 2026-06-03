import 'package:shopkeeper/core/enums/message_role.dart';
import 'package:shopkeeper/features/ai_chat/domain/entities/chat_message.dart';

class MockData {
  static final List<ChatMessage> chatMessages = [
    ChatMessage(
      id: 'm1',
      role: MessageRole.user,
      text: 'How much did I make this week compared to last week?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      id: 'm2',
      role: MessageRole.assistant,
      text:
          'This week you made 187,500 FCFA from 43 transactions, up 14% from last week. Beverages led at 60% of revenue.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    ChatMessage(
      id: 'm3',
      role: MessageRole.user,
      text: 'Who owes me the most money?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    ChatMessage(
      id: 'm4',
      role: MessageRole.assistant,
      text:
          'Paul Tchamba has the highest balance at 40,300 FCFA with no purchase in 14 days. Jean-Pierre Foka owes 25,000 FCFA and is flagged High Risk.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];
}
