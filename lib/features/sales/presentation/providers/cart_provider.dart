import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/enums/price_type.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/sales/domain/entities/cart_item.dart';

@injectable
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  // Payment details set on PaymentScreen, read by SaleConfirmScreen.
  double _paidAmount = 0;
  bool _isCredit = false;
  String? _customerId;

  List<CartItem> get items => List.unmodifiable(_items);
  double get paidAmount => _paidAmount;
  bool get isCredit => _isCredit;
  String? get customerId => _customerId;

  double get total =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  int get itemCount => _items.length;

  bool get isEmpty => _items.isEmpty;

  // ── Cart management ───────────────────────────────────────────────────────

  void addToCart(Product product, {PriceType priceType = PriceType.retail}) {
    final idx = _items.indexWhere(
      (i) => i.product.id == product.id && i.priceType == priceType,
    );
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
    } else {
      _items.add(CartItem(
        id: '${product.id}_${priceType.name}',
        product: product,
        quantity: 1,
        priceType: priceType,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int qty) {
    if (qty <= 0) {
      removeItem(cartItemId);
      return;
    }
    final idx = _items.indexWhere((i) => i.id == cartItemId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: qty);
      notifyListeners();
    }
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((i) => i.id == cartItemId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _paidAmount = 0;
    _isCredit = false;
    _customerId = null;
    notifyListeners();
  }

  // ── Payment state ─────────────────────────────────────────────────────────

  void setPayment({
    required double paidAmount,
    required bool isCredit,
    String? customerId,
  }) {
    _paidAmount = paidAmount;
    _isCredit = isCredit;
    _customerId = customerId;
    notifyListeners();
  }
}
