import 'package:flutter_test/flutter_test.dart';
import 'package:shopkeeper/core/enums/debt_type.dart';
import 'package:shopkeeper/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:shopkeeper/features/debts/data/models/customer_model.dart';
import 'package:shopkeeper/features/debts/data/models/debt_record_model.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/domain/entities/debt_record.dart';
import 'package:shopkeeper/features/products/data/models/product_model.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/sales/data/models/sale_item_model.dart';
import 'package:shopkeeper/features/sales/data/models/sale_model.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale_item.dart';

void main() {
  // ── ProductModel ──────────────────────────────────────────────────────────

  group('ProductModel', () {
    final jsonData = {
      'id': 'prod-1',
      'shop_id': 'shop-1',
      'name': 'Coca-Cola',
      'category': 'Beverages',
      'base_unit': 'Bottle',
      'units': [
        {'name': 'Bottle', 'quantity_in_base': 1, 'price': 500},
        {'name': 'Carton', 'quantity_in_base': 24, 'price': 10000},
      ],
      'stock_qty': 48,
      'low_stock_threshold': 5,
      'is_active': true,
    };

    test('fromJson parses all fields correctly', () {
      final model = ProductModel.fromJson(jsonData);
      expect(model.id, 'prod-1');
      expect(model.shopId, 'shop-1');
      expect(model.name, 'Coca-Cola');
      expect(model.category, 'Beverages');
      expect(model.baseUnit, 'Bottle');
      expect(model.units.length, 2);
      expect(model.units.first.name, 'Bottle');
      expect(model.units.first.quantityInBase, 1);
      expect(model.units.first.price, 500.0);
      expect(model.stockQty, 48);
      expect(model.lowStockThreshold, 5);
      expect(model.isActive, isTrue);
    });

    test('fromJson uses defaults for missing fields', () {
      final model = ProductModel.fromJson({});
      expect(model.id, '');
      expect(model.name, '');
      expect(model.units, isEmpty);
      expect(model.stockQty, 0);
      expect(model.isActive, isTrue);
    });

    test('toJson round-trips correctly', () {
      final model = ProductModel.fromJson(jsonData);
      final json = model.toJson();
      expect(json['id'], 'prod-1');
      expect(json['shop_id'], 'shop-1');
      expect(json['name'], 'Coca-Cola');
      expect(json['stock_qty'], 48);
      expect(json['is_active'], isTrue);
      final units = json['units'] as List;
      expect(units.length, 2);
      expect((units.first as Map)['name'], 'Bottle');
    });

    test('toCreateRequest contains required create fields', () {
      final model = ProductModel.fromJson(jsonData);
      final req = model.toCreateRequest();
      expect(req['shop_id'], 'shop-1');
      expect(req['name'], 'Coca-Cola');
      expect(req['category'], 'Beverages');
      expect(req.containsKey('initial_stock'), isTrue);
      expect(req.containsKey('low_stock_threshold'), isTrue);
    });

    test('toUpdateRequest contains required update fields', () {
      final model = ProductModel.fromJson(jsonData);
      final req = model.toUpdateRequest();
      expect(req['name'], 'Coca-Cola');
      expect(req['category'], 'Beverages');
      expect(req.containsKey('units'), isTrue);
      expect(req.containsKey('low_stock_threshold'), isTrue);
      expect(req.containsKey('id'), isFalse);
    });

    test('fromEntity maps entity fields to model', () {
      const entity = Product(
        id: 'e-1',
        shopId: 's-1',
        name: 'Test',
        category: 'Other',
        units: [
          UnitDefinition(name: 'Box', quantityInBase: 1, price: 200),
        ],
        stockQty: 10,
        lowStockThreshold: 2,
        isActive: true,
      );
      final model = ProductModel.fromEntity(entity);
      expect(model.id, 'e-1');
      expect(model.name, 'Test');
      expect(model.units.first.name, 'Box');
    });

    test('toEntity converts model to domain entity', () {
      final model = ProductModel.fromJson(jsonData);
      final entity = model.toEntity();
      expect(entity.id, 'prod-1');
      expect(entity.name, 'Coca-Cola');
      expect(entity.units.length, 2);
    });
  });

  // ── SaleItemModel ─────────────────────────────────────────────────────────

  group('SaleItemModel', () {
    final jsonData = {
      'product_id': 'prod-1',
      'unit': 'Bottle',
      'quantity': 5,
      'unit_price': 500.0,
      'total_price': 2500.0,
    };

    test('fromJson parses all fields', () {
      final model = SaleItemModel.fromJson(jsonData);
      expect(model.productId, 'prod-1');
      expect(model.unit, 'Bottle');
      expect(model.quantity, 5);
      expect(model.unitPrice, 500.0);
      expect(model.totalPrice, 2500.0);
    });

    test('fromJson uses defaults for missing fields', () {
      final model = SaleItemModel.fromJson({});
      expect(model.productId, '');
      expect(model.unit, '');
      expect(model.quantity, 0);
      expect(model.unitPrice, 0.0);
      expect(model.totalPrice, 0.0);
    });

    test('toJson round-trips correctly', () {
      final model = SaleItemModel.fromJson(jsonData);
      final json = model.toJson();
      expect(json['product_id'], 'prod-1');
      expect(json['unit'], 'Bottle');
      expect(json['quantity'], 5);
      expect(json['unit_price'], 500.0);
      expect(json['total_price'], 2500.0);
    });

    test('fromEntity maps entity fields', () {
      const entity = SaleItem(
        productId: 'p-1',
        unit: 'Box',
        quantity: 3,
        unitPrice: 100,
        totalPrice: 300,
      );
      final model = SaleItemModel.fromEntity(entity);
      expect(model.productId, 'p-1');
      expect(model.unit, 'Box');
      expect(model.quantity, 3);
    });

    test('toEntity converts to domain entity', () {
      final model = SaleItemModel.fromJson(jsonData);
      final entity = model.toEntity();
      expect(entity.productId, 'prod-1');
      expect(entity.quantity, 5);
      expect(entity.totalPrice, 2500.0);
    });
  });

  // ── SaleModel ─────────────────────────────────────────────────────────────

  group('SaleModel', () {
    final jsonData = {
      'id': 'sale-1',
      'shop_id': 'shop-1',
      'owner_id': 'owner-1',
      'customer_id': 'cust-1',
      'items': [
        {
          'product_id': 'prod-1',
          'unit': 'Bottle',
          'quantity': 7,
          'unit_price': 500.0,
          'total_price': 3500.0,
        }
      ],
      'total_amount': 3500.0,
      'paid_amount': 3500.0,
      'due_amount': 0.0,
      'is_credit': false,
      'is_paid': true,
      'created_at': '2026-06-10T10:00:00.000Z',
    };

    test('fromJson parses all fields', () {
      final model = SaleModel.fromJson(jsonData);
      expect(model.id, 'sale-1');
      expect(model.shopId, 'shop-1');
      expect(model.ownerId, 'owner-1');
      expect(model.customerId, 'cust-1');
      expect(model.items.length, 1);
      expect(model.items.first.productId, 'prod-1');
      expect(model.totalAmount, 3500.0);
      expect(model.paidAmount, 3500.0);
      expect(model.dueAmount, 0.0);
      expect(model.isCredit, isFalse);
      expect(model.isPaid, isTrue);
    });

    test('fromJson with null customer_id', () {
      final json = Map<String, dynamic>.from(jsonData)..remove('customer_id');
      final model = SaleModel.fromJson(json);
      expect(model.customerId, isNull);
    });

    test('fromJson with empty items list', () {
      final json = Map<String, dynamic>.from(jsonData);
      json['items'] = <dynamic>[];
      final model = SaleModel.fromJson(json);
      expect(model.items, isEmpty);
    });

    test('fromJson uses defaults for missing fields', () {
      final model = SaleModel.fromJson({'created_at': null});
      expect(model.id, '');
      expect(model.totalAmount, 0.0);
      expect(model.isCredit, isFalse);
    });

    test('toJson round-trips correctly', () {
      final model = SaleModel.fromJson(jsonData);
      final json = model.toJson();
      expect(json['id'], 'sale-1');
      expect(json['shop_id'], 'shop-1');
      expect(json['customer_id'], 'cust-1');
      expect(json['total_amount'], 3500.0);
      expect(json['is_credit'], isFalse);
      expect((json['items'] as List).length, 1);
    });

    test('fromEntity maps entity fields', () {
      final entity = Sale(
        id: 's-1',
        shopId: 'sh-1',
        ownerId: 'o-1',
        items: const [
          SaleItem(
            productId: 'p-1',
            unit: 'Box',
            quantity: 2,
            unitPrice: 100,
            totalPrice: 200,
          ),
        ],
        totalAmount: 200,
        paidAmount: 200,
        dueAmount: 0,
        isCredit: false,
        isPaid: true,
        createdAt: DateTime(2026, 1, 1),
      );
      final model = SaleModel.fromEntity(entity);
      expect(model.id, 's-1');
      expect(model.items.length, 1);
      expect(model.totalAmount, 200);
    });

    test('toEntity converts to domain entity', () {
      final model = SaleModel.fromJson(jsonData);
      final entity = model.toEntity();
      expect(entity.id, 'sale-1');
      expect(entity.items.length, 1);
      expect(entity.totalAmount, 3500.0);
    });
  });

  // ── CustomerModel ─────────────────────────────────────────────────────────

  group('CustomerModel', () {
    final jsonData = {
      'id': 'cust-1',
      'shop_id': 'shop-1',
      'name': 'Alice Doe',
      'phone': '237670001122',
      'total_debt': 5000.0,
      'created_at': '2026-01-01T00:00:00.000Z',
    };

    test('fromJson parses all fields', () {
      final model = CustomerModel.fromJson(jsonData);
      expect(model.id, 'cust-1');
      expect(model.shopId, 'shop-1');
      expect(model.name, 'Alice Doe');
      expect(model.phone, '237670001122');
      expect(model.totalDebt, 5000.0);
    });

    test('fromJson uses empty string for missing phone', () {
      final json = Map<String, dynamic>.from(jsonData)..remove('phone');
      final model = CustomerModel.fromJson(json);
      expect(model.phone, '');
    });

    test('toJson round-trips correctly', () {
      final model = CustomerModel.fromJson(jsonData);
      final json = model.toJson();
      expect(json['id'], 'cust-1');
      expect(json['name'], 'Alice Doe');
      expect(json['total_debt'], 5000.0);
    });

    test('toEntity converts to domain entity', () {
      final model = CustomerModel.fromJson(jsonData);
      final entity = model.toEntity();
      expect(entity.id, 'cust-1');
      expect(entity.name, 'Alice Doe');
      expect(entity.totalDebt, 5000.0);
    });
  });

  // ── DebtRecordModel ───────────────────────────────────────────────────────

  group('DebtRecordModel', () {
    final creditJson = {
      'id': 'rec-1',
      'customer_id': 'cust-1',
      'type': 'credit',
      'amount': 3500.0,
      'balance_after': 3500.0,
      'note': null,
      'recorded_at': '2026-06-10T10:00:00.000Z',
    };

    final paymentJson = {
      'id': 'rec-2',
      'customer_id': 'cust-1',
      'type': 'payment',
      'amount': 1000.0,
      'balance_after': 2500.0,
      'note': 'Partial payment',
      'recorded_at': '2026-06-11T10:00:00.000Z',
    };

    test('fromJson parses credit type', () {
      final model = DebtRecordModel.fromJson(creditJson);
      expect(model.id, 'rec-1');
      expect(model.type, DebtType.credit);
      expect(model.amount, 3500.0);
      expect(model.note, isNull);
    });

    test('fromJson parses payment type', () {
      final model = DebtRecordModel.fromJson(paymentJson);
      expect(model.type, DebtType.payment);
      expect(model.amount, 1000.0);
      expect(model.note, 'Partial payment');
      expect(model.balanceAfter, 2500.0);
    });

    test('toJson serializes type as string', () {
      final model = DebtRecordModel.fromJson(creditJson);
      final json = model.toJson();
      expect(json['type'], 'credit');
      expect(json['id'], 'rec-1');
      expect(json['amount'], 3500.0);
    });

    test('toJson serializes payment type', () {
      final model = DebtRecordModel.fromJson(paymentJson);
      final json = model.toJson();
      expect(json['type'], 'payment');
      expect(json['note'], 'Partial payment');
    });

    test('fromEntity maps entity fields', () {
      final entity = DebtRecord(
        id: 'dr-1',
        customerId: 'c-1',
        type: DebtType.credit,
        amount: 500,
        balanceAfter: 500,
        note: 'Test',
        recordedAt: DateTime(2026, 3, 1),
      );
      final model = DebtRecordModel.fromEntity(entity);
      expect(model.id, 'dr-1');
      expect(model.type, DebtType.credit);
      expect(model.note, 'Test');
    });

    test('toEntity converts to domain entity', () {
      final model = DebtRecordModel.fromJson(creditJson);
      final entity = model.toEntity();
      expect(entity.id, 'rec-1');
      expect(entity.type, DebtType.credit);
      expect(entity.amount, 3500.0);
    });

    test('copyWith creates new instance with updated fields', () {
      final model = DebtRecordModel.fromJson(creditJson);
      final updated = model.copyWith(amount: 9999, note: 'Updated');
      expect(updated.id, 'rec-1');
      expect(updated.amount, 9999);
      expect(updated.note, 'Updated');
      expect(model.amount, 3500.0);
    });

    test('copyWith preserves unchanged fields', () {
      final model = DebtRecordModel.fromJson(paymentJson);
      final updated = model.copyWith(type: DebtType.credit);
      expect(updated.customerId, model.customerId);
      expect(updated.balanceAfter, model.balanceAfter);
    });
  });

  // ── DashboardStatsModel ───────────────────────────────────────────────────

  group('DashboardStatsModel', () {
    final jsonData = {
      'today_sales': 7500.0,
      'transaction_count': 5,
      'low_stock_count': 2,
      'total_debts': 12000.0,
      'weekly_revenue': [1000.0, 2000.0, 1500.0, 3000.0, 7500.0, 0.0, 0.0],
      'activity_feed': [
        {
          'id': 'act-1',
          'title': 'Sale recorded',
          'subtitle': 'Cash • FCFA 3,500',
          'timestamp': '2026-06-10T09:30:00.000Z',
          'type': 'sale',
        }
      ],
    };

    test('fromJson parses all fields', () {
      final model = DashboardStatsModel.fromJson(jsonData);
      expect(model.todaySales, 7500.0);
      expect(model.transactionCount, 5);
      expect(model.lowStockCount, 2);
      expect(model.totalDebts, 12000.0);
      expect(model.weeklyRevenue.length, 7);
      expect(model.weeklyRevenue[4], 7500.0);
      expect(model.activityFeed.length, 1);
    });

    test('fromJson defaults weekly_revenue when not a list', () {
      final json = Map<String, dynamic>.from(jsonData);
      json['weekly_revenue'] = null;
      final model = DashboardStatsModel.fromJson(json);
      expect(model.weeklyRevenue, List.filled(7, 0));
    });

    test('fromJson uses 0 defaults for missing numeric fields', () {
      final model = DashboardStatsModel.fromJson({'activity_feed': []});
      expect(model.todaySales, 0);
      expect(model.transactionCount, 0);
    });

    test('toJson round-trips correctly', () {
      final model = DashboardStatsModel.fromJson(jsonData);
      final json = model.toJson();
      expect(json['today_sales'], 7500.0);
      expect(json['transaction_count'], 5);
      expect((json['activity_feed'] as List).length, 1);
    });

    test('toEntity converts to DashboardStats entity', () {
      final model = DashboardStatsModel.fromJson(jsonData);
      final entity = model.toEntity();
      expect(entity.todaySales, 7500.0);
      expect(entity.activityFeed.length, 1);
    });

    group('ActivityFeedModel', () {
      final actJson = {
        'id': 'act-2',
        'title': 'Credit sale',
        'subtitle': 'Alice • FCFA 5,000',
        'timestamp': '2026-06-10T08:00:00.000Z',
        'type': 'credit_sale',
      };

      test('fromJson parses all fields', () {
        final model = ActivityFeedModel.fromJson(actJson);
        expect(model.id, 'act-2');
        expect(model.title, 'Credit sale');
        expect(model.subtitle, 'Alice • FCFA 5,000');
        expect(model.type, 'credit_sale');
      });

      test('toJson serializes correctly', () {
        final model = ActivityFeedModel.fromJson(actJson);
        final json = model.toJson();
        expect(json['id'], 'act-2');
        expect(json['title'], 'Credit sale');
        expect(json['type'], 'credit_sale');
      });

      test('toEntity converts to ActivityFeed entity', () {
        final model = ActivityFeedModel.fromJson(actJson);
        final entity = model.toEntity();
        expect(entity.id, 'act-2');
        expect(entity.title, 'Credit sale');
        expect(entity.type, 'credit_sale');
      });
    });
  });

  // ── Customer entity ───────────────────────────────────────────────────────

  group('Customer entity', () {
    test('copyWith creates updated instance', () {
      final c = Customer(
        id: 'c-1',
        shopId: 's-1',
        name: 'Bob',
        phone: '123',
        totalDebt: 1000,
        createdAt: DateTime(2026, 1, 1),
      );
      final updated = c.copyWith(totalDebt: 2000);
      expect(updated.id, 'c-1');
      expect(updated.totalDebt, 2000);
      expect(c.totalDebt, 1000);
    });
  });
}
