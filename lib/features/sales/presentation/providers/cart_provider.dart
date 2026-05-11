import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class CartProvider extends ChangeNotifier {
  List<dynamic> _items = [];

  List<dynamic> get items => List.unmodifiable(_items);

  void addItem(dynamic item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double get total => 0.0;
}
