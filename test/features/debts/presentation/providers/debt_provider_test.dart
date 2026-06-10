import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/domain/entities/debt_record.dart';
import 'package:shopkeeper/features/debts/domain/repositories/i_debt_repository.dart';

import '../../../../helpers/fake_providers.dart';

// ── Test repositories ─────────────────────────────────────────────────────────

class _SuccessDebtRepo implements IDebtRepository {
  final Customer _customer;
  _SuccessDebtRepo(this._customer);

  @override
  TaskEither<Failure, List<Customer>> getCustomers(
          {required String shopId, bool? hasDebt}) =>
      TaskEither.right([_customer]);

  @override
  TaskEither<Failure, Customer> getCustomerById(String id) =>
      TaskEither.right(_customer);

  @override
  TaskEither<Failure, Customer> createCustomer(
          {required String shopId, required String name, String? phone}) =>
      TaskEither.right(_customer);

  @override
  TaskEither<Failure, List<DebtRecord>> getDebtHistory(String customerId) =>
      TaskEither.right([]);

  @override
  TaskEither<Failure, Unit> recordPayment(
          String customerId, double amount, String? note) =>
      TaskEither.right(unit);
}

class _FailingDebtRepo implements IDebtRepository {
  final String message;
  _FailingDebtRepo([this.message = 'Server error']);

  @override
  TaskEither<Failure, List<Customer>> getCustomers(
          {required String shopId, bool? hasDebt}) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, Customer> getCustomerById(String id) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, Customer> createCustomer(
          {required String shopId, required String name, String? phone}) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, List<DebtRecord>> getDebtHistory(String customerId) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, Unit> recordPayment(
          String customerId, double amount, String? note) =>
      TaskEither.left(ServerFailure(message));
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── createCustomer ────────────────────────────────────────────────────────

  group('DebtProvider — createCustomer success', () {
    test('returns customer and prepends to list', () async {
      final p = buildDebtProvider(_SuccessDebtRepo(testCustomer));
      final result =
          await p.createCustomer(shopId: 'shop-1', name: 'Alice Doe');
      expect(result, testCustomer);
      expect(p.customers, [testCustomer]);
      expect(p.errorMessage, isNull);
    });

    test('isSaving is false after completion', () async {
      final p = buildDebtProvider(_SuccessDebtRepo(testCustomer));
      await p.createCustomer(shopId: 'shop-1', name: 'Alice Doe');
      expect(p.isSaving, isFalse);
    });
  });

  group('DebtProvider — createCustomer failure', () {
    test('sets errorMessage and returns null', () async {
      final p = buildDebtProvider(_FailingDebtRepo('Duplicate name'));
      final result =
          await p.createCustomer(shopId: 'shop-1', name: 'Alice Doe');
      expect(result, isNull);
      expect(p.errorMessage, 'Duplicate name');
      expect(p.customers, isEmpty);
    });
  });

  // ── recordPayment ─────────────────────────────────────────────────────────

  group('DebtProvider — recordPayment success', () {
    test('returns true and reduces customer debt', () async {
      final p = buildDebtProvider(_SuccessDebtRepo(testCustomer));
      // pre-populate with a customer who has 5000 debt
      await p.createCustomer(shopId: 'shop-1', name: testCustomer.name);

      final success = await p.recordPayment(testCustomer.id, 1000, 'partial');
      expect(success, isTrue);
      expect(p.customers.first.totalDebt, 4000.0);
      expect(p.errorMessage, isNull);
    });

    test('clamps debt to 0 when payment exceeds balance', () async {
      final p = buildDebtProvider(_SuccessDebtRepo(testCustomer));
      await p.createCustomer(shopId: 'shop-1', name: testCustomer.name);

      final success = await p.recordPayment(testCustomer.id, 99999, null);
      expect(success, isTrue);
      expect(p.customers.first.totalDebt, 0.0);
    });
  });

  group('DebtProvider — recordPayment failure', () {
    test('returns false and sets errorMessage', () async {
      final p = buildDebtProvider(_FailingDebtRepo('Payment failed'));
      final success = await p.recordPayment('cust-1', 500, null);
      expect(success, isFalse);
      expect(p.errorMessage, 'Payment failed');
    });
  });

  // ── computed getters ──────────────────────────────────────────────────────

  group('DebtProvider — totalOutstandingDebt', () {
    test('is 0 when no customers', () {
      final p = buildDebtProvider(_FailingDebtRepo());
      expect(p.totalOutstandingDebt, 0.0);
    });

    test('sums totalDebt across all customers after loading', () async {
      final c1 = testCustomer; // totalDebt = 5000
      final p = buildDebtProvider(_SuccessDebtRepo(c1), online: true);
      await p.loadCustomers('shop-1');
      expect(p.totalOutstandingDebt, 5000.0);
    });
  });

  group('DebtProvider — customersWithDebt', () {
    test('returns empty when no customers', () {
      final p = buildDebtProvider(_FailingDebtRepo());
      expect(p.customersWithDebt, isEmpty);
    });

    test('includes only customers with totalDebt > 0', () async {
      final withDebt = testCustomer; // totalDebt = 5000
      final p = buildDebtProvider(_SuccessDebtRepo(withDebt), online: true);
      await p.loadCustomers('shop-1');
      expect(p.customersWithDebt, [withDebt]);
    });
  });

  // ── clearError ────────────────────────────────────────────────────────────

  group('DebtProvider — clearError', () {
    test('clears errorMessage', () async {
      final p = buildDebtProvider(_FailingDebtRepo('oops'));
      await p.createCustomer(shopId: 'shop-1', name: 'x');
      expect(p.errorMessage, 'oops');

      p.clearError();
      expect(p.errorMessage, isNull);
    });
  });

  // ── loadCustomers offline ─────────────────────────────────────────────────

  group('DebtProvider — loadCustomers offline', () {
    test('stays empty with no cache and no network', () async {
      final p =
          buildDebtProvider(_SuccessDebtRepo(testCustomer), online: false);
      await p.loadCustomers('shop-1');
      expect(p.customers, isEmpty);
      expect(p.isLoading, isFalse);
    });
  });

  // ── loadCustomers online ──────────────────────────────────────────────────

  group('DebtProvider — loadCustomers online', () {
    test('populates customers from repo on success', () async {
      final p = buildDebtProvider(_SuccessDebtRepo(testCustomer), online: true);
      await p.loadCustomers('shop-1');
      expect(p.customers, [testCustomer]);
      expect(p.isLoading, isFalse);
      expect(p.isRefreshing, isFalse);
    });

    test('sets errorMessage when repo fails and list is empty', () async {
      final p = buildDebtProvider(_FailingDebtRepo('Offline'), online: true);
      await p.loadCustomers('shop-1');
      expect(p.errorMessage, 'Offline');
    });
  });

  // ── loadCustomerDetail online ─────────────────────────────────────────────

  group('DebtProvider — loadCustomerDetail online', () {
    test('sets selectedCustomer on success', () async {
      final p = buildDebtProvider(_SuccessDebtRepo(testCustomer), online: true);
      await p.loadCustomerDetail(testCustomer.id);
      expect(p.selectedCustomer, testCustomer);
      expect(p.isLoading, isFalse);
    });

    test('sets errorMessage when customer not found', () async {
      final p = buildDebtProvider(_FailingDebtRepo('Not found'), online: true);
      await p.loadCustomerDetail('missing-id');
      expect(p.errorMessage, 'Not found');
    });
  });
}
