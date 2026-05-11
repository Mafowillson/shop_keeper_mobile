import 'package:flutter/foundation.dart';
import 'package:shopkeeper/core/enums/message_role.dart';

@immutable
class ChatMessage {
  final String id;
  final MessageRole role;
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
  });

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? text,
    DateTime? timestamp,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        role: role ?? this.role,
        text: text ?? this.text,
        timestamp: timestamp ?? this.timestamp,
      );
}
