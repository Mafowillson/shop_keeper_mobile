import 'package:shopkeeper/core/enums/message_role.dart';
import 'package:shopkeeper/features/ai_chat/domain/entities/chat_message.dart';

class ChatMessageModel {
  final String id;
  final MessageRole role;
  final String text;
  final DateTime timestamp;

  const ChatMessageModel({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'],
        role: _parseRole(json['role'] as String),
        text: json['text'],
        timestamp: DateTime.parse(json['created_at'] ?? json['timestamp']),
      );

  static MessageRole _parseRole(String raw) {
    if (raw == 'model') return MessageRole.assistant;
    return MessageRole.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => MessageRole.assistant,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.toString().split('.').last,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessageModel.fromEntity(ChatMessage entity) => ChatMessageModel(
        id: entity.id,
        role: entity.role,
        text: entity.text,
        timestamp: entity.timestamp,
      );

  ChatMessage toEntity() => ChatMessage(
        id: id,
        role: role,
        text: text,
        timestamp: timestamp,
      );

  ChatMessageModel copyWith({
    String? id,
    MessageRole? role,
    String? text,
    DateTime? timestamp,
  }) =>
      ChatMessageModel(
        id: id ?? this.id,
        role: role ?? this.role,
        text: text ?? this.text,
        timestamp: timestamp ?? this.timestamp,
      );
}
