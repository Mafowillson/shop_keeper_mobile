import 'package:shopkeeper/core/enums/notification_type.dart';
import 'package:shopkeeper/features/notifications/domain/entities/app_notification.dart';

class NotificationModel {
  final String id;
  final String shopId;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId;

  const NotificationModel({
    required this.id,
    required this.shopId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.relatedId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json['id'],
    shopId: json['shop_id'],
    type: NotificationType.values.firstWhere(
      (e) => e.toString() == 'NotificationType.${json['type']}',
    ),
    title: json['title'],
    body: json['body'],
    isRead: json['is_read'],
    createdAt: DateTime.parse(json['created_at']),
    relatedId: json['related_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop_id': shopId,
    'type': type.toString().split('.').last,
    'title': title,
    'body': body,
    'is_read': isRead,
    'created_at': createdAt.toIso8601String(),
    'related_id': relatedId,
  };

  factory NotificationModel.fromEntity(AppNotification entity) => NotificationModel(
    id: entity.id,
    shopId: entity.shopId,
    type: entity.type,
    title: entity.title,
    body: entity.body,
    isRead: entity.isRead,
    createdAt: entity.createdAt,
    relatedId: entity.relatedId,
  );

  AppNotification toEntity() => AppNotification(
    id: id,
    shopId: shopId,
    type: type,
    title: title,
    body: body,
    isRead: isRead,
    createdAt: createdAt,
    relatedId: relatedId,
  );

  NotificationModel copyWith({
    String? id,
    String? shopId,
    NotificationType? type,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
    String? relatedId,
  }) =>
      NotificationModel(
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
