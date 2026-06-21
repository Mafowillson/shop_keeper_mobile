import 'package:flutter/material.dart';

@immutable
class FraudAlert {
  final String id;
  final String shopId;
  final String saleId;
  final String triggerType; // "large_sale", "off_hours", "rapid_credit"
  final String details;
  final String status; // "open", "acknowledged"
  final DateTime createdAt;
  final DateTime? acknowledgedAt;

  const FraudAlert({
    required this.id,
    required this.shopId,
    required this.saleId,
    required this.triggerType,
    required this.details,
    required this.status,
    required this.createdAt,
    this.acknowledgedAt,
  });

  bool get isOpen => status == 'open';

  String get triggerLabel {
    switch (triggerType) {
      case 'large_sale':
        return 'Large Sale';
      case 'off_hours':
        return 'Off Hours';
      case 'rapid_credit':
        return 'Rapid Credit';
      default:
        return triggerType;
    }
  }

  IconData get triggerIcon {
    switch (triggerType) {
      case 'large_sale':
        return Icons.trending_up;
      case 'off_hours':
        return Icons.schedule;
      case 'rapid_credit':
        return Icons.credit_card;
      default:
        return Icons.warning;
    }
  }

  FraudAlert copyWith({String? status, DateTime? acknowledgedAt}) => FraudAlert(
        id: id,
        shopId: shopId,
        saleId: saleId,
        triggerType: triggerType,
        details: details,
        status: status ?? this.status,
        createdAt: createdAt,
        acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      );
}
