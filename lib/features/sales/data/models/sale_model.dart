import 'package:shopkeeper/features/sales/data/models/sale_item_model.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';

class SaleModel {
  final String id;
  final String shopId;
  final String ownerId;
  final String? customerId;
  final List<SaleItemModel> items;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final bool isCredit;
  final bool isPaid;
  final DateTime createdAt;

  const SaleModel({
    required this.id,
    required this.shopId,
    required this.ownerId,
    this.customerId,
    required this.items,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.isCredit,
    required this.isPaid,
    required this.createdAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return SaleModel(
      id: json['id'] as String? ?? '',
      shopId: json['shop_id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      customerId: json['customer_id'] as String?,
      items: rawItems
          .cast<Map<String, dynamic>>()
          .map(SaleItemModel.fromJson)
          .toList(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (json['due_amount'] as num?)?.toDouble() ?? 0.0,
      isCredit: json['is_credit'] as bool? ?? false,
      isPaid: json['is_paid'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'shop_id': shopId,
        'owner_id': ownerId,
        'customer_id': customerId,
        'items': items.map((i) => i.toJson()).toList(),
        'total_amount': totalAmount,
        'paid_amount': paidAmount,
        'due_amount': dueAmount,
        'is_credit': isCredit,
        'is_paid': isPaid,
        'created_at': createdAt.toIso8601String(),
      };

  factory SaleModel.fromEntity(Sale entity) => SaleModel(
        id: entity.id,
        shopId: entity.shopId,
        ownerId: entity.ownerId,
        customerId: entity.customerId,
        items: entity.items.map(SaleItemModel.fromEntity).toList(),
        totalAmount: entity.totalAmount,
        paidAmount: entity.paidAmount,
        dueAmount: entity.dueAmount,
        isCredit: entity.isCredit,
        isPaid: entity.isPaid,
        createdAt: entity.createdAt,
      );

  Sale toEntity() => Sale(
        id: id,
        shopId: shopId,
        ownerId: ownerId,
        customerId: customerId,
        items: items.map((i) => i.toEntity()).toList(),
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        dueAmount: dueAmount,
        isCredit: isCredit,
        isPaid: isPaid,
        createdAt: createdAt,
      );
}
