import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/sales/domain/entities/cart_item.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/domain/repositories/i_sale_repository.dart';

import '../../../../helpers/fake_providers.dart';

// ── Test repositories ─────────────────────────────────────────────────────────

class _SuccessSaleRepo implements ISaleRepository {
  final Sale _sale;
  _SuccessSaleRepo(this._sale);

  @override
  TaskEither<Failure, Sale> recordSale({
    required String shopId,
    required List<CartItem> cartItems,
    required double paidAmount,
    required bool isCredit,
    String? customerId,
  }) =>
      TaskEither.right(_sale);

  @override
  TaskEither<Failure, List<Sale>> getSales({required String shopId}) =>
      TaskEither.right([_sale]);

  @override
  TaskEither<Failure, Sale> getSaleById(String id) => TaskEither.right(_sale);
}

class _FailingSaleRepo implements ISaleRepository {
  final String message;
  _FailingSaleRepo([this.message = 'Server error']);

  @override
  TaskEither<Failure, Sale> recordSale({
    required String shopId,
    required List<CartItem> cartItems,
    required double paidAmount,
    required bool isCredit,
    String? customerId,
  }) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, List<Sale>> getSales({required String shopId}) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, Sale> getSaleById(String id) =>
      TaskEither.left(ServerFailure(message));
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── recordSale ────────────────────────────────────────────────────────────

  group('SalesProvider — recordSale success', () {
    test('returns the sale and prepends it to sales list', () async {
      final sale = makeSale();
      final p = buildSalesProvider(_SuccessSaleRepo(sale));

      final result = await p.recordSale(
        shopId: 'shop-1',
        cartItems: [],
        paidAmount: 500,
        isCredit: false,
      );

      expect(result, sale);
      expect(p.sales, [sale]);
      expect(p.currentSale, sale);
      expect(p.errorMessage, isNull);
    });

    test('isRecording is false after completion', () async {
      final p = buildSalesProvider(_SuccessSaleRepo(makeSale()));
      await p.recordSale(
          shopId: 'shop-1', cartItems: [], paidAmount: 500, isCredit: false);
      expect(p.isRecording, isFalse);
    });
  });

  group('SalesProvider — recordSale failure', () {
    test('sets errorMessage and returns null', () async {
      final p = buildSalesProvider(_FailingSaleRepo('Network error'));

      final result = await p.recordSale(
        shopId: 'shop-1',
        cartItems: [],
        paidAmount: 500,
        isCredit: false,
      );

      expect(result, isNull);
      expect(p.errorMessage, 'Network error');
      expect(p.sales, isEmpty);
    });

    test('isRecording is false after failure', () async {
      final p = buildSalesProvider(_FailingSaleRepo());
      await p.recordSale(
          shopId: 'shop-1', cartItems: [], paidAmount: 500, isCredit: false);
      expect(p.isRecording, isFalse);
    });
  });

  // ── totalRevenue ──────────────────────────────────────────────────────────

  group('SalesProvider — totalRevenue', () {
    test('is 0 initially', () {
      final p = buildSalesProvider(_FailingSaleRepo());
      expect(p.totalRevenue, 0.0);
    });

    test('equals totalAmount of recorded sale', () async {
      final sale = makeSale(totalAmount: 3500);
      final p = buildSalesProvider(_SuccessSaleRepo(sale));
      await p.recordSale(
          shopId: 'shop-1', cartItems: [], paidAmount: 3500, isCredit: false);
      expect(p.totalRevenue, 3500.0);
    });

    test('accumulates across multiple recorded sales', () async {
      final s1 = makeSale(id: 'sale-1', totalAmount: 1000);
      final s2 = makeSale(id: 'sale-2', totalAmount: 2500);
      final p = buildSalesProvider(_SuccessSaleRepo(s1));
      await p.recordSale(
          shopId: 'shop-1', cartItems: [], paidAmount: 1000, isCredit: false);

      final p2 = buildSalesProvider(_SuccessSaleRepo(s2));
      await p2.recordSale(
          shopId: 'shop-1', cartItems: [], paidAmount: 2500, isCredit: false);

      expect(p.totalRevenue, 1000.0);
      expect(p2.totalRevenue, 2500.0);
    });
  });

  // ── clearError ────────────────────────────────────────────────────────────

  group('SalesProvider — clearError', () {
    test('clears errorMessage after failure', () async {
      final p = buildSalesProvider(_FailingSaleRepo('oops'));
      await p.recordSale(
          shopId: 'shop-1', cartItems: [], paidAmount: 0, isCredit: false);
      expect(p.errorMessage, 'oops');

      p.clearError();
      expect(p.errorMessage, isNull);
    });
  });

  // ── loadSales offline ─────────────────────────────────────────────────────

  group('SalesProvider — loadSales offline', () {
    test('sales stays empty with empty cache and no network', () async {
      final p = buildSalesProvider(_SuccessSaleRepo(makeSale()), online: false);
      await p.loadSales('shop-1');
      expect(p.sales, isEmpty);
      expect(p.isLoading, isFalse);
    });
  });

  // ── loadSales online ──────────────────────────────────────────────────────

  group('SalesProvider — loadSales online', () {
    test('populates sales from repo on success', () async {
      final sale = makeSale();
      final p = buildSalesProvider(_SuccessSaleRepo(sale), online: true);
      await p.loadSales('shop-1');
      expect(p.sales, [sale]);
      expect(p.isLoading, isFalse);
      expect(p.isRefreshing, isFalse);
    });

    test('sets errorMessage when repo fails and sales is empty', () async {
      final p = buildSalesProvider(_FailingSaleRepo('Net error'), online: true);
      await p.loadSales('shop-1');
      expect(p.errorMessage, 'Net error');
      expect(p.isLoading, isFalse);
    });
  });

  // ── loadSaleDetail online ─────────────────────────────────────────────────

  group('SalesProvider — loadSaleDetail online', () {
    test('sets currentSale on success', () async {
      final sale = makeSale();
      final p = buildSalesProvider(_SuccessSaleRepo(sale), online: true);
      await p.loadSaleDetail('sale-abcd1234-5678');
      expect(p.currentSale, sale);
      expect(p.isLoading, isFalse);
    });

    test('sets errorMessage on failure when currentSale is null', () async {
      final p = buildSalesProvider(_FailingSaleRepo('Not found'), online: true);
      await p.loadSaleDetail('missing-id');
      expect(p.errorMessage, 'Not found');
    });
  });
}
