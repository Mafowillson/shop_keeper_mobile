import 'package:flutter/foundation.dart';
import 'package:shopkeeper/core/enums/notification_type.dart';

@immutable
class AppNotification {
  final String id;
  final String shopId;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId;

  const AppNotification({
    required this.id,
    required this.shopId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.relatedId,
  });

  AppNotification copyWith({
    String? id,
    String? shopId,
    NotificationType? type,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
    String? relatedId,
  }) =>
      AppNotification(
        id: id ?? this.id,
        shopId: shopId ?? this.shopId,
        type: type ?? this.type,
        title: title ?? this.title,
        body: body ?? this.body,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt ?? this.createdAt,
        relatedId: relatedId ?? this.relatedId,
      );
}
