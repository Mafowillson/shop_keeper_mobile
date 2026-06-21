import 'package:shopkeeper/features/debts/domain/entities/customer.dart';

class CustomerModel {
  final String id;
  final String shopId;
  final String name;
  final String phone;
  final double totalDebt;
  final DateTime createdAt;

  /// Backend-computed AI risk fields — never sent to the API.
  final String? riskLevel;
  final int? riskScore;

  const CustomerModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.phone,
    required this.totalDebt,
    required this.createdAt,
    this.riskLevel,
    this.riskScore,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] as String,
        shopId: json['shop_id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String? ?? '',
        totalDebt: (json['total_debt'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
        riskLevel: json['risk_level'] as String?,
        riskScore: json['risk_score'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'shop_id': shopId,
        'name': name,
        'phone': phone,
        'total_debt': totalDebt,
        'created_at': createdAt.toIso8601String(),
      };

  Customer toEntity() => Customer(
        id: id,
        shopId: shopId,
        name: name,
        phone: phone,
        totalDebt: totalDebt,
        createdAt: createdAt,
        riskLevel: riskLevel,
        riskScore: riskScore,
      );
}
