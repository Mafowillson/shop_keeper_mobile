import 'package:shopkeeper/core/enums/debt_type.dart';
import 'package:shopkeeper/features/debts/domain/entities/debt_record.dart';

class DebtRecordModel {
  final String id;
  final String customerId;
  final DebtType type;
  final double amount;
  final double balanceAfter;
  final String? note;
  final DateTime recordedAt;

  const DebtRecordModel({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.note,
    required this.recordedAt,
  });

  factory DebtRecordModel.fromJson(Map<String, dynamic> json) => DebtRecordModel(
    id: json['id'],
    customerId: json['customer_id'],
    type: DebtType.values.firstWhere(
      (e) => e.toString() == 'DebtType.${json['type']}',
    ),
    amount: (json['amount'] as num).toDouble(),
    balanceAfter: (json['balance_after'] as num).toDouble(),
    note: json['note'],
    recordedAt: DateTime.parse(json['recorded_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer_id': customerId,
    'type': type.toString().split('.').last,
    'amount': amount,
    'balance_after': balanceAfter,
    'note': note,
    'recorded_at': recordedAt.toIso8601String(),
  };

  factory DebtRecordModel.fromEntity(DebtRecord entity) => DebtRecordModel(
    id: entity.id,
    customerId: entity.customerId,
    type: entity.type,
    amount: entity.amount,
    balanceAfter: entity.balanceAfter,
    note: entity.note,
    recordedAt: entity.recordedAt,
  );

  DebtRecord toEntity() => DebtRecord(
    id: id,
    customerId: customerId,
    type: type,
    amount: amount,
    balanceAfter: balanceAfter,
    note: note,
    recordedAt: recordedAt,
  );

  DebtRecordModel copyWith({
    String? id,
    String? customerId,
    DebtType? type,
    double? amount,
    double? balanceAfter,
    String? note,
    DateTime? recordedAt,
  }) =>
      DebtRecordModel(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        balanceAfter: balanceAfter ?? this.balanceAfter,
        note: note ?? this.note,
        recordedAt: recordedAt ?? this.recordedAt,
      );
}
