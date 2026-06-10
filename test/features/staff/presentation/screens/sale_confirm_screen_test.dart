import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:shopkeeper/features/debts/presentation/providers/debt_provider.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/sales/presentation/providers/cart_provider.dart';
import 'package:shopkeeper/features/sales/presentation/providers/sales_provider.dart';
import 'package:shopkeeper/features/staff/presentation/screens/sale_confirm_screen.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

import '../../../../helpers/fake_providers.dart';

// ── Router ────────────────────────────────────────────────────────────────────

GoRouter _router() => GoRouter(
      initialLocation: '/confirm',
      routes: [
        GoRoute(
            path: '/confirm', builder: (_, __) => const SaleConfirmScreen()),
        GoRoute(
            path: '/owner/dashboard',
            builder: (_, __) => const Scaffold(body: Text('Dashboard'))),
        GoRoute(
            path: '/staff/home',
            builder: (_, __) => const Scaffold(body: Text('Home'))),
      ],
    );

// ── Helpers ───────────────────────────────────────────────────────────────────

CartProvider _cartWithItem() {
  final c = CartProvider();
  c.addToCart(
    makeProduct(),
    unit: const UnitDefinition(name: 'Bottle', quantityInBase: 1, price: 500),
  );
  c.setPayment(paidAmount: 500, isCredit: false);
  return c;
}

Widget _buildApp({
  User user = testOwner,
  CartProvider? cart,
  SalesProvider? sales,
  FakeDebtProvider? debt,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(
          value: FakeAuthProvider(currentUser: user)),
      ChangeNotifierProvider<CartProvider>.value(
          value: cart ?? _cartWithItem()),
      ChangeNotifierProvider<DebtProvider>.value(
          value: debt ?? FakeDebtProvider()),
      ChangeNotifierProvider<SalesProvider>.value(
          value: sales ?? FakeSalesProvider(saleToReturn: makeSale())),
      ChangeNotifierProvider<DashboardProvider>.value(
          value: FakeDashboardProvider()),
    ],
    child: MaterialApp.router(
      routerConfig: _router(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Loading state ──────────────────────────────────────────────────────────

  group('SaleConfirmScreen — loading state', () {
    testWidgets('shows spinner while submitting', (tester) async {
      // FakeSalesProviderPending never resolves so _isSubmitting stays true
      await tester.pumpWidget(_buildApp(sales: FakeSalesProviderPending()));
      await tester.pump(); // fires post-frame callback → _isSubmitting = true
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows Processing label while submitting', (tester) async {
      await tester.pumpWidget(_buildApp(sales: FakeSalesProviderPending()));
      await tester.pump();
      expect(find.textContaining('Processing'), findsOneWidget);
    });
  });

  // ── Success state ──────────────────────────────────────────────────────────

  group('SaleConfirmScreen — success state', () {
    testWidgets('shows Payment Successful on success', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Payment Successful!'), findsOneWidget);
    });

    testWidgets('shows success check icon', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('shows sale reference from sale id', (tester) async {
      final sale = makeSale(id: 'abcd1234-xxxx-xxxx');
      await tester
          .pumpWidget(_buildApp(sales: FakeSalesProvider(saleToReturn: sale)));
      await tester.pumpAndSettle();
      // first 8 chars uppercased: 'ABCD1234'
      expect(find.textContaining('ABCD1234'), findsOneWidget);
    });

    testWidgets('shows product name in receipt', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // makeProduct() name is 'Coca-Cola'
      expect(find.text('Coca-Cola'), findsOneWidget);
    });

    testWidgets('shows Walk-in Customer when no customer on cart',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Walk-in Customer'), findsOneWidget);
    });

    testWidgets('shows named customer when cart has customer id',
        (tester) async {
      final cart = _cartWithItem()
        ..setPayment(
            paidAmount: 500, isCredit: false, customerId: testCustomer.id);
      final debt = FakeDebtProvider(customers: [testCustomer]);
      await tester.pumpWidget(_buildApp(cart: cart, debt: debt));
      await tester.pumpAndSettle();
      expect(find.text(testCustomer.name), findsOneWidget);
    });

    testWidgets('shows total amount in receipt', (tester) async {
      final sale = makeSale(totalAmount: 3500, paidAmount: 3500);
      await tester
          .pumpWidget(_buildApp(sales: FakeSalesProvider(saleToReturn: sale)));
      await tester.pumpAndSettle();
      expect(find.textContaining('3500'), findsWidgets);
    });

    testWidgets('shows credit owed row for credit sale', (tester) async {
      final sale = makeSale(totalAmount: 3500, paidAmount: 0, isCredit: true);
      await tester
          .pumpWidget(_buildApp(sales: FakeSalesProvider(saleToReturn: sale)));
      await tester.pumpAndSettle();
      expect(find.text('Owed (credit)'), findsOneWidget);
    });
  });

  // ── Error state ────────────────────────────────────────────────────────────

  group('SaleConfirmScreen — error state', () {
    testWidgets('shows error icon when sale fails', (tester) async {
      final sales =
          FakeSalesProvider(saleToReturn: null, errorMessage: 'Network error');
      await tester.pumpWidget(_buildApp(sales: sales));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows error message from provider', (tester) async {
      final sales =
          FakeSalesProvider(saleToReturn: null, errorMessage: 'Network error');
      await tester.pumpWidget(_buildApp(sales: sales));
      await tester.pumpAndSettle();
      expect(find.text('Network error'), findsWidgets);
    });

    testWidgets('shows Try Again button on error', (tester) async {
      final sales =
          FakeSalesProvider(saleToReturn: null, errorMessage: 'Network error');
      await tester.pumpWidget(_buildApp(sales: sales));
      await tester.pumpAndSettle();
      expect(find.text('Try Again'), findsOneWidget);
    });
  });

  // ── Action buttons ─────────────────────────────────────────────────────────

  group('SaleConfirmScreen — action buttons', () {
    testWidgets('shows Share Receipt button', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Share Receipt'), findsOneWidget);
    });

    testWidgets('shows PDF Receipt button', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('PDF Receipt'), findsOneWidget);
    });

    testWidgets('shows New Sale button', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('New Sale'), findsOneWidget);
    });
  });

  // ── Staff user ─────────────────────────────────────────────────────────────

  group('SaleConfirmScreen — staff user', () {
    testWidgets('shows success screen for staff without calling dashboard',
        (tester) async {
      await tester.pumpWidget(_buildApp(user: testStaffUser));
      await tester.pumpAndSettle();
      expect(find.text('Payment Successful!'), findsOneWidget);
    });
  });
}
