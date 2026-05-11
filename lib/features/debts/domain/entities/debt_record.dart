import 'package:flutter/foundation.dart';
import 'package:shopkeeper/core/enums/debt_type.dart';

@immutable
class DebtRecord {
  final String id;
  final String customerId;
  final DebtType type;
  final double amount;
  final double balanceAfter;
  final String? note;
  final DateTime recordedAt;

  const DebtRecord({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.note,
    required this.recordedAt,
  });

  DebtRecord copyWith({
    String? id,
    String? customerId,
    DebtType? type,
    double? amount,
    double? balanceAfter,
    String? note,
    DateTime? recordedAt,
  }) =>
      DebtRecord(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        balanceAfter: balanceAfter ?? this.balanceAfter,
        note: note ?? this.note,
        recordedAt: recordedAt ?? this.recordedAt,
      );
}
