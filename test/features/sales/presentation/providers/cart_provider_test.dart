import 'package:flutter_test/flutter_test.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/sales/presentation/providers/cart_provider.dart';

import '../../../../helpers/fake_providers.dart';

void main() {
  late CartProvider cart;

  const bottle = UnitDefinition(name: 'Bottle', quantityInBase: 1, price: 500);
  const carton =
      UnitDefinition(name: 'Carton', quantityInBase: 24, price: 10000);

  setUp(() => cart = CartProvider());

  // ── Initial state ─────────────────────────────────────────────────────────

  group('CartProvider — initial state', () {
    test('is empty on creation', () {
      expect(cart.isEmpty, isTrue);
      expect(cart.itemCount, 0);
      expect(cart.total, 0.0);
      expect(cart.paidAmount, 0.0);
      expect(cart.isCredit, isFalse);
      expect(cart.customerId, isNull);
    });
  });

  // ── addToCart ─────────────────────────────────────────────────────────────

  group('CartProvider — addToCart', () {
    test('adds a new item', () {
      cart.addToCart(makeProduct(), unit: bottle);
      expect(cart.itemCount, 1);
      expect(cart.isEmpty, isFalse);
    });

    test('increments quantity when same product+unit added again', () {
      cart.addToCart(makeProduct(), unit: bottle);
      cart.addToCart(makeProduct(), unit: bottle);
      expect(cart.itemCount, 1);
      expect(cart.items.first.quantity, 2);
    });

    test('treats same product with different unit as separate items', () {
      cart.addToCart(makeProduct(), unit: bottle);
      cart.addToCart(makeProduct(), unit: carton);
      expect(cart.itemCount, 2);
    });

    test('treats different products as separate items', () {
      cart.addToCart(makeProduct(id: 'prod-1'), unit: bottle);
      cart.addToCart(makeProduct(id: 'prod-2'), unit: bottle);
      expect(cart.itemCount, 2);
    });

    test('total reflects sum of all item subtotals', () {
      cart.addToCart(makeProduct(id: 'prod-1'), unit: bottle); // 500
      cart.addToCart(makeProduct(id: 'prod-2'), unit: carton); // 10000
      expect(cart.total, 10500.0);
    });

    test('total updates when quantity increments', () {
      cart.addToCart(makeProduct(), unit: bottle); // 500
      cart.addToCart(makeProduct(), unit: bottle); // +500
      expect(cart.total, 1000.0);
    });
  });

  // ── updateQuantity ────────────────────────────────────────────────────────

  group('CartProvider — updateQuantity', () {
    test('updates item quantity', () {
      cart.addToCart(makeProduct(), unit: bottle);
      cart.updateQuantity('prod-1_Bottle', 5);
      expect(cart.items.first.quantity, 5);
      expect(cart.total, 2500.0);
    });

    test('removes item when quantity set to 0', () {
      cart.addToCart(makeProduct(), unit: bottle);
      cart.updateQuantity('prod-1_Bottle', 0);
      expect(cart.isEmpty, isTrue);
    });

    test('removes item when quantity set to negative', () {
      cart.addToCart(makeProduct(), unit: bottle);
      cart.updateQuantity('prod-1_Bottle', -1);
      expect(cart.isEmpty, isTrue);
    });

    test('no-ops when item id not found', () {
      cart.addToCart(makeProduct(), unit: bottle);
      cart.updateQuantity('nonexistent', 5);
      expect(cart.itemCount, 1);
      expect(cart.items.first.quantity, 1);
    });
  });

  // ── removeItem ────────────────────────────────────────────────────────────

  group('CartProvider — removeItem', () {
    test('removes the matching item', () {
      cart.addToCart(makeProduct(), unit: bottle);
      cart.removeItem('prod-1_Bottle');
      expect(cart.isEmpty, isTrue);
    });

    test('leaves other items intact', () {
      cart.addToCart(makeProduct(id: 'prod-1'), unit: bottle);
      cart.addToCart(makeProduct(id: 'prod-2'), unit: bottle);
      cart.removeItem('prod-1_Bottle');
      expect(cart.itemCount, 1);
      expect(cart.items.first.product.id, 'prod-2');
    });
  });

  // ── setPayment / clear ────────────────────────────────────────────────────

  group('CartProvider — setPayment', () {
    test('stores paid amount, isCredit, and customerId', () {
      cart.setPayment(paidAmount: 5000, isCredit: false, customerId: 'cust-1');
      expect(cart.paidAmount, 5000.0);
      expect(cart.isCredit, isFalse);
      expect(cart.customerId, 'cust-1');
    });

    test('stores credit sale with no customer', () {
      cart.setPayment(paidAmount: 0, isCredit: true);
      expect(cart.isCredit, isTrue);
      expect(cart.customerId, isNull);
    });
  });

  group('CartProvider — clear', () {
    test('resets all state to initial', () {
      cart.addToCart(makeProduct(), unit: bottle);
      cart.setPayment(paidAmount: 500, isCredit: false, customerId: 'cust-1');

      cart.clear();

      expect(cart.isEmpty, isTrue);
      expect(cart.itemCount, 0);
      expect(cart.total, 0.0);
      expect(cart.paidAmount, 0.0);
      expect(cart.isCredit, isFalse);
      expect(cart.customerId, isNull);
    });
  });
}
