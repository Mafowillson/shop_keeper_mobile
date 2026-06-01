import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/domain/usecases/deactivate_product_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/get_products_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/save_product_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/search_products_usecase.dart';

@injectable
class ProductProvider extends ChangeNotifier {
  final GetProductsUseCase _getProducts;
  final SaveProductUseCase _saveProduct;
  final DeactivateProductUseCase _deactivateProduct;
  final SearchProductsUseCase _searchProducts;

  ProductProvider(
    this._getProducts,
    this._saveProduct,
    this._deactivateProduct,
    this._searchProducts,
  );

  List<Product> _products = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList()..sort();
    return cats;
  }

  Future<void> loadProducts(String shopId, {String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getProducts(shopId: shopId, category: category).run();

    result.fold(
      (f) => _errorMessage = f.message,
      (list) => _products = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchProducts(String query, String shopId) async {
    if (query.isEmpty) {
      await loadProducts(shopId);
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _searchProducts(query, shopId: shopId).run();

    result.fold(
      (f) => _errorMessage = f.message,
      (list) => _products = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Returns the saved product on success, null on failure (error in [errorMessage]).
  Future<Product?> saveProduct(Product product) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    Product? saved;
    final result = await _saveProduct(product).run();

    result.fold(
      (f) => _errorMessage = f.message,
      (p) {
        saved = p;
        // Update in-place or prepend.
        final idx = _products.indexWhere((x) => x.id == p.id);
        if (idx >= 0) {
          _products[idx] = p;
        } else {
          _products = [p, ..._products];
        }
      },
    );

    _isSaving = false;
    notifyListeners();
    return saved;
  }

  Future<bool> deactivateProduct(String id) async {
    _errorMessage = null;
    final result = await _deactivateProduct(id).run();

    return result.fold(
      (f) {
        _errorMessage = f.message;
        notifyListeners();
        return false;
      },
      (_) {
        _products = _products.where((p) => p.id != id).toList();
        notifyListeners();
        return true;
      },
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
