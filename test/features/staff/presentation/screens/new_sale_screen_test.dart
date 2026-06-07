import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';
import 'package:shopkeeper/features/sales/presentation/providers/cart_provider.dart';
import 'package:shopkeeper/features/staff/presentation/screens/new_sale_screen.dart';

import '../../../../helpers/fake_providers.dart';

GoRouter _router() => GoRouter(
      initialLocation: '/new-sale',
      routes: [
        GoRoute(
          path: '/new-sale',
          builder: (_, __) => const NewSaleScreen(),
        ),
        GoRoute(
          path: '/staff/sale/payment',
          builder: (_, __) => const Scaffold(body: Text('Payment')),
        ),
      ],
    );

Widget _buildTestApp({
  FakeAuthProvider? auth,
  FakeProductProvider? products,
  CartProvider? cart,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(
          value: auth ?? FakeAuthProvider(currentUser: testOwner)),
      ChangeNotifierProvider<ProductProvider>.value(
          value: products ?? FakeProductProvider()),
      ChangeNotifierProvider<CartProvider>.value(value: cart ?? CartProvider()),
    ],
    child: MaterialApp.router(routerConfig: _router()),
  );
}

void main() {
  group('NewSaleScreen — layout', () {
    testWidgets('shows New Sale title in AppBar', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('New Sale'), findsOneWidget);
    });

    testWidgets('shows search products hint text', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Search products…'), findsOneWidget);
    });

    testWidgets('shows shopping cart icon in AppBar', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });
  });

  group('NewSaleScreen — loading state', () {
    testWidgets('shows CircularProgressIndicator when products are loading',
        (tester) async {
      final pp = FakeProductProvider(isLoading: true);
      await tester.pumpWidget(_buildTestApp(products: pp));
      await tester.pump(); // don't settle — spinner is live

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('NewSaleScreen — empty state', () {
    testWidgets('shows empty-state icon when product list is empty',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('shows No products in this category when list is empty',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('No products in this category'), findsOneWidget);
    });

    testWidgets('shows All category chip when products are present',
        (tester) async {
      final pp = FakeProductProvider(products: [makeProduct()]);
      await tester.pumpWidget(_buildTestApp(products: pp));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
    });
  });

  group('NewSaleScreen — product cards', () {
    testWidgets('shows product name on card', (tester) async {
      final pp =
          FakeProductProvider(products: [makeProduct(name: 'Fanta Orange')]);
      await tester.pumpWidget(_buildTestApp(products: pp));
      await tester.pumpAndSettle();

      expect(find.text('Fanta Orange'), findsOneWidget);
    });

    testWidgets('shows In Stock chip for stocked product', (tester) async {
      final pp = FakeProductProvider(products: [makeProduct(stock: 20)]);
      await tester.pumpWidget(_buildTestApp(products: pp));
      await tester.pumpAndSettle();

      expect(find.text('In Stock'), findsOneWidget);
    });

    testWidgets('shows Out of Stock chip for product with zero stock',
        (tester) async {
      final pp = FakeProductProvider(products: [makeProduct(stock: 0)]);
      await tester.pumpWidget(_buildTestApp(products: pp));
      await tester.pumpAndSettle();

      expect(find.text('Out of Stock'), findsOneWidget);
    });

    testWidgets('shows Add button for in-stock product', (tester) async {
      final pp = FakeProductProvider(products: [makeProduct(stock: 10)]);
      await tester.pumpWidget(_buildTestApp(products: pp));
      await tester.pumpAndSettle();

      expect(find.text('Add'), findsWidgets);
    });

    testWidgets('shows FCFA price for product unit', (tester) async {
      final pp = FakeProductProvider(products: [makeProduct()]);
      await tester.pumpWidget(_buildTestApp(products: pp));
      await tester.pumpAndSettle();

      // makeProduct gives Bottle at 500 FCFA
      expect(find.textContaining('FCFA 500'), findsOneWidget);
    });

    testWidgets('shows product category chip', (tester) async {
      final pp =
          FakeProductProvider(products: [makeProduct(category: 'Drinks')]);
      await tester.pumpWidget(_buildTestApp(products: pp));
      await tester.pumpAndSettle();

      // Category appears both in the category bar and in the product card pill
      expect(find.text('Drinks'), findsWidgets);
    });
  });

  group('NewSaleScreen — search', () {
    testWidgets('shows no-match empty state when search finds nothing',
        (tester) async {
      final pp =
          FakeProductProvider(products: [makeProduct(name: 'Fanta Orange')]);
      await tester.pumpWidget(_buildTestApp(products: pp));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'ZZZ_no_match');
      await tester.pump();

      expect(find.text('No products match your search'), findsOneWidget);
    });
  });

  group('NewSaleScreen — cart integration', () {
    testWidgets('checkout bar is not visible when cart is empty',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsNothing);
    });

    testWidgets('checkout bar appears after adding item to cart',
        (tester) async {
      final cart = CartProvider();
      final product = makeProduct(stock: 10);
      cart.addToCart(product,
          unit: const UnitDefinition(
              name: 'Bottle', quantityInBase: 1, price: 500));

      final pp = FakeProductProvider(products: [product]);
      await tester.pumpWidget(_buildTestApp(products: pp, cart: cart));
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsOneWidget);
    });

    testWidgets('checkout bar shows correct item count', (tester) async {
      final cart = CartProvider();
      final product = makeProduct(stock: 10);
      cart.addToCart(product,
          unit: const UnitDefinition(
              name: 'Bottle', quantityInBase: 1, price: 500));

      final pp = FakeProductProvider(products: [product]);
      await tester.pumpWidget(_buildTestApp(products: pp, cart: cart));
      await tester.pumpAndSettle();

      // itemCount == 1
      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('checkout bar shows total price', (tester) async {
      final cart = CartProvider();
      final product = makeProduct(stock: 10);
      cart.addToCart(product,
          unit: const UnitDefinition(
              name: 'Bottle', quantityInBase: 1, price: 500));

      final pp = FakeProductProvider(products: [product]);
      await tester.pumpWidget(_buildTestApp(products: pp, cart: cart));
      await tester.pumpAndSettle();

      expect(find.textContaining('FCFA 500'), findsWidgets);
    });

    testWidgets('cart icon badge shows count when cart is not empty',
        (tester) async {
      final cart = CartProvider();
      final product = makeProduct(stock: 10);
      cart.addToCart(product,
          unit: const UnitDefinition(
              name: 'Bottle', quantityInBase: 1, price: 500));

      final pp = FakeProductProvider(products: [product]);
      await tester.pumpWidget(_buildTestApp(products: pp, cart: cart));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsWidgets);
    });
  });
}
