import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/debts/presentation/providers/debt_provider.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/sales/presentation/providers/cart_provider.dart';
import 'package:shopkeeper/features/staff/presentation/screens/payment_screen.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

import '../../../../helpers/fake_providers.dart';

// ── Router ────────────────────────────────────────────────────────────────────

GoRouter _router() => GoRouter(
      initialLocation: '/payment',
      routes: [
        GoRoute(path: '/payment', builder: (_, __) => const PaymentScreen()),
        GoRoute(
            path: '/owner/sale/confirm',
            builder: (_, __) => const Scaffold(body: Text('SaleConfirmStub'))),
        GoRoute(
            path: '/staff/sale/confirm',
            builder: (_, __) => const Scaffold(body: Text('SaleConfirmStub'))),
      ],
    );

// ── Helpers ───────────────────────────────────────────────────────────────────

CartProvider _cartWith({int qty = 1}) {
  final c = CartProvider();
  for (int i = 0; i < qty; i++) {
    c.addToCart(
      makeProduct(),
      unit: const UnitDefinition(name: 'Bottle', quantityInBase: 1, price: 500),
    );
  }
  return c;
}

Widget _buildApp({
  User user = testOwner,
  CartProvider? cart,
  FakeDebtProvider? debt,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(
          value: FakeAuthProvider(currentUser: user)),
      ChangeNotifierProvider<CartProvider>.value(value: cart ?? _cartWith()),
      ChangeNotifierProvider<DebtProvider>.value(
          value: debt ?? FakeDebtProvider()),
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
  // ── Layout ──────────────────────────────────────────────────────────────────

  group('PaymentScreen — layout', () {
    testWidgets('shows Payment in AppBar', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Payment'), findsOneWidget);
    });

    testWidgets('shows cart total in header', (tester) async {
      await tester.pumpWidget(_buildApp(cart: _cartWith(qty: 7))); // 3500
      await tester.pumpAndSettle();
      expect(find.textContaining('3500'), findsWidgets);
    });

    testWidgets('shows Cash chip', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Cash'), findsOneWidget);
    });

    testWidgets('shows Credit chip', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Credit'), findsOneWidget);
    });

    testWidgets('amount field is initialised to 0', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final tf = tester.widget<TextField>(find.byType(TextField).first);
      expect(tf.controller?.text, '0');
    });

    testWidgets('shows Confirm button', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Confirm'), findsOneWidget);
    });
  });

  // ── Customer section ─────────────────────────────────────────────────────────

  group('PaymentScreen — customer section', () {
    testWidgets('shows Walk-in Customer by default in cash mode',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Walk-in Customer'), findsOneWidget);
    });

    testWidgets('shows select customer hint in credit mode', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Credit'));
      await tester.pumpAndSettle();
      expect(find.text('Walk-in Customer'), findsNothing);
    });

    testWidgets(
        'shows customer required warning in credit mode with no customer',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Credit'));
      await tester.pumpAndSettle();
      expect(find.textContaining('required'), findsOneWidget);
    });

    testWidgets(
        'shows customer with debt in picker when debt provider has customers',
        (tester) async {
      final debt = FakeDebtProvider(customers: [testCustomer]);
      await tester.pumpWidget(_buildApp(debt: debt));
      await tester.pumpAndSettle();
      // customer is in the provider but not yet selected — Walk-in shown
      expect(find.text('Walk-in Customer'), findsOneWidget);
    });
  });

  // ── Cash mode summary card ────────────────────────────────────────────────

  group('PaymentScreen — cash mode summary', () {
    testWidgets('shows Total row', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('shows Paid row', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Paid'), findsOneWidget);
    });

    testWidgets('shows Change row when amount >= total', (tester) async {
      await tester.pumpWidget(_buildApp(cart: _cartWith())); // total=500
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '1000');
      await tester.pump();

      expect(find.text('Change'), findsOneWidget);
    });

    testWidgets('shows Owed row when amount < total', (tester) async {
      await tester.pumpWidget(_buildApp(cart: _cartWith())); // total=500
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '200');
      await tester.pump();

      expect(find.text('Owed'), findsOneWidget);
    });

    testWidgets('shows partial payment banner when amount < total',
        (tester) async {
      await tester.pumpWidget(_buildApp(cart: _cartWith())); // total=500
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '200');
      await tester.pump();

      expect(find.textContaining('debt'), findsOneWidget);
    });

    testWidgets('no partial payment banner when amount >= total',
        (tester) async {
      await tester.pumpWidget(_buildApp(cart: _cartWith())); // total=500
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '500');
      await tester.pump();

      expect(find.textContaining('debt'), findsNothing);
    });
  });

  // ── Credit mode ───────────────────────────────────────────────────────────

  group('PaymentScreen — credit mode', () {
    testWidgets('switching to credit hides the amount field', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Credit'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('shows full-amount-as-debt info banner', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Credit'));
      await tester.pumpAndSettle();

      expect(find.textContaining('debt'), findsOneWidget);
    });
  });

  // ── Staff vs owner ────────────────────────────────────────────────────────

  group('PaymentScreen — role', () {
    testWidgets('renders correctly for staff user', (tester) async {
      await tester.pumpWidget(_buildApp(user: testStaffUser));
      await tester.pumpAndSettle();
      expect(find.text('Payment'), findsOneWidget);
    });

    testWidgets('renders correctly for owner user', (tester) async {
      await tester.pumpWidget(_buildApp(user: testOwner));
      await tester.pumpAndSettle();
      expect(find.text('Payment'), findsOneWidget);
    });
  });

  // ── Confirm navigation ────────────────────────────────────────────────────

  group('PaymentScreen — confirm navigation', () {
    testWidgets('tapping Confirm with full amount navigates to confirm route',
        (tester) async {
      await tester.pumpWidget(_buildApp(cart: _cartWith())); // total = 500
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '500');
      await tester.pump();

      // Confirm button may be below fold — scroll it into view first.
      await tester.ensureVisible(find.text('Confirm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Stub confirm screen is now on top
      expect(find.text('SaleConfirmStub'), findsOneWidget);
    });

    testWidgets(
        'tapping Confirm with partial amount and no customer stays on screen',
        (tester) async {
      await tester.pumpWidget(_buildApp(cart: _cartWith())); // total = 500
      await tester.pumpAndSettle();

      // Enter 200 < 500 total — _canProceed returns false (no customer)
      await tester.enterText(find.byType(TextField).first, '200');
      await tester.pump();

      // Confirm button is disabled — tapping does nothing
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Still on Payment screen
      expect(find.text('Payment'), findsOneWidget);
    });
  });

  // ── Customer picker ───────────────────────────────────────────────────────

  group('PaymentScreen — customer picker', () {
    // Use a tall surface so the DraggableScrollableSheet has room to render.
    Future<void> setTallSurface(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
    }

    void resetSurface(WidgetTester tester) {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }

    testWidgets('tapping customer row opens picker sheet', (tester) async {
      await setTallSurface(tester);
      addTearDown(() => resetSurface(tester));

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Walk-in Customer'));
      await tester.pumpAndSettle();

      expect(find.text('Select Customer'), findsOneWidget);
    });

    testWidgets('picker shows walk-in Default badge in cash mode',
        (tester) async {
      await setTallSurface(tester);
      addTearDown(() => resetSurface(tester));

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Walk-in Customer'));
      await tester.pumpAndSettle();

      expect(find.text('Default'), findsOneWidget);
    });

    testWidgets('picker shows empty state when no customers', (tester) async {
      await setTallSurface(tester);
      addTearDown(() => resetSurface(tester));

      await tester.pumpWidget(_buildApp()); // FakeDebtProvider has no customers
      await tester.pumpAndSettle();

      await tester.tap(find.text('Walk-in Customer'));
      await tester.pumpAndSettle();

      expect(find.text('No customers found'), findsOneWidget);
    });

    testWidgets('picker shows customer tile when customers are loaded',
        (tester) async {
      await setTallSurface(tester);
      addTearDown(() => resetSurface(tester));

      final debt = FakeDebtProvider(customers: [testCustomer]);
      await tester.pumpWidget(_buildApp(debt: debt));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Walk-in Customer'));
      await tester.pumpAndSettle();

      expect(find.text(testCustomer.name), findsOneWidget);
    });

    testWidgets('selecting customer in picker updates main screen',
        (tester) async {
      await setTallSurface(tester);
      addTearDown(() => resetSurface(tester));

      final debt = FakeDebtProvider(customers: [testCustomer]);
      await tester.pumpWidget(_buildApp(debt: debt));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Walk-in Customer'));
      await tester.pumpAndSettle();

      // Tap on customer tile to select it
      await tester.tap(find.text(testCustomer.name));
      await tester.pumpAndSettle();

      // Walk-in text replaced by selected customer name
      expect(find.text('Walk-in Customer'), findsNothing);
      expect(find.text(testCustomer.name), findsOneWidget);
    });
  });
}
