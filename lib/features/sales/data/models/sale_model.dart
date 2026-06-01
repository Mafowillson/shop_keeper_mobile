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
