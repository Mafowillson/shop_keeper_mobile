import 'package:shopkeeper/features/ai/fraud_alerts/domain/entities/fraud_alert.dart';

class FraudAlertModel {
  final String id;
  final String shopId;
  final String saleId;
  final String triggerType;
  final String details;
  final String status;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;

  const FraudAlertModel({
    required this.id,
    required this.shopId,
    required this.saleId,
    required this.triggerType,
    required this.details,
    required this.status,
    required this.createdAt,
    this.acknowledgedAt,
  });

  factory FraudAlertModel.fromJson(Map<String, dynamic> json) =>
      FraudAlertModel(
        id: json['id'] as String,
        shopId: json['shop_id'] as String,
        saleId: json['sale_id'] as String? ?? '',
        triggerType: json['trigger_type'] as String? ?? '',
        details: json['details'] as String? ?? '',
        status: json['status'] as String? ?? 'open',
        createdAt: DateTime.parse(json['created_at'] as String),
        acknowledgedAt: json['acknowledged_at'] != null
            ? DateTime.parse(json['acknowledged_at'] as String)
            : null,
      );

  FraudAlert toEntity() => FraudAlert(
        id: id,
        shopId: shopId,
        saleId: saleId,
        triggerType: triggerType,
        details: details,
        status: status,
        createdAt: createdAt,
        acknowledgedAt: acknowledgedAt,
      );
}
