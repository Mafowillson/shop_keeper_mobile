import 'package:shopkeeper/features/sales/domain/entities/sale.dart';

class SaleModel {
  final String id;
  final String shopId;
  final DateTime saleDate;
  final double totalAmount;
  final bool isCredit;
  final String? customerId;
  final String staffId;

  const SaleModel({
    required this.id,
    required this.shopId,
    required this.saleDate,
    required this.totalAmount,
    required this.isCredit,
    this.customerId,
    required this.staffId,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
    id: json['id'],
    shopId: json['shop_id'],
    saleDate: DateTime.parse(json['sale_date']),
    totalAmount: (json['total_amount'] as num).toDouble(),
    isCredit: json['is_credit'],
    customerId: json['customer_id'],
    staffId: json['staff_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop_id': shopId,
    'sale_date': saleDate.toIso8601String(),
    'total_amount': totalAmount,
    'is_credit': isCredit,
    'customer_id': customerId,
    'staff_id': staffId,
  };

  factory SaleModel.fromEntity(Sale entity) => SaleModel(
    id: entity.id,
    shopId: entity.shopId,
    saleDate: entity.saleDate,
    totalAmount: entity.totalAmount,
    isCredit: entity.isCredit,
    customerId: entity.customerId,
    staffId: entity.staffId,
  );

  Sale toEntity() => Sale(
    id: id,
    shopId: shopId,
    saleDate: saleDate,
    totalAmount: totalAmount,
    isCredit: isCredit,
    customerId: customerId,
    staffId: staffId,
  );

  SaleModel copyWith({
    String? id,
    String? shopId,
    DateTime? saleDate,
    double? totalAmount,
    bool? isCredit,
    String? customerId,
    String? staffId,
  }) =>
      SaleModel(
        id: id ?? this.id,
        shopId: shopId ?? this.shopId,
        saleDate: saleDate ?? this.saleDate,
        totalAmount: totalAmount ?? this.totalAmount,
        isCredit: isCredit ?? this.isCredit,
        customerId: customerId ?? this.customerId,
        staffId: staffId ?? this.staffId,
      );
}
