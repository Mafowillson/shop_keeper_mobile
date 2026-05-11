import 'package:shopkeeper/core/enums/risk_category.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';

class CustomerModel {
  final String id;
  final String shopId;
  final String name;
  final String phone;
  final double totalDebt;
  final RiskCategory riskCategory;
  final int lastPurchaseDaysAgo;

  const CustomerModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.phone,
    required this.totalDebt,
    required this.riskCategory,
    required this.lastPurchaseDaysAgo,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: json['id'],
    shopId: json['shop_id'],
    name: json['name'],
    phone: json['phone'],
    totalDebt: (json['total_debt'] as num).toDouble(),
    riskCategory: RiskCategory.values.firstWhere(
      (e) => e.toString() == 'RiskCategory.${json['risk_category']}',
    ),
    lastPurchaseDaysAgo: json['last_purchase_days_ago'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop_id': shopId,
    'name': name,
    'phone': phone,
    'total_debt': totalDebt,
    'risk_category': riskCategory.toString().split('.').last,
    'last_purchase_days_ago': lastPurchaseDaysAgo,
  };

  factory CustomerModel.fromEntity(Customer entity) => CustomerModel(
    id: entity.id,
    shopId: entity.shopId,
    name: entity.name,
    phone: entity.phone,
    totalDebt: entity.totalDebt,
    riskCategory: entity.riskCategory,
    lastPurchaseDaysAgo: entity.lastPurchaseDaysAgo,
  );

  Customer toEntity() => Customer(
    id: id,
    shopId: shopId,
    name: name,
    phone: phone,
    totalDebt: totalDebt,
    riskCategory: riskCategory,
    lastPurchaseDaysAgo: lastPurchaseDaysAgo,
  );

  CustomerModel copyWith({
    String? id,
    String? shopId,
    String? name,
    String? phone,
    double? totalDebt,
    RiskCategory? riskCategory,
    int? lastPurchaseDaysAgo,
  }) =>
      CustomerModel(
        id: id ?? this.id,
        shopId: shopId ?? this.shopId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        totalDebt: totalDebt ?? this.totalDebt,
        riskCategory: riskCategory ?? this.riskCategory,
        lastPurchaseDaysAgo: lastPurchaseDaysAgo ?? this.lastPurchaseDaysAgo,
      );
}
