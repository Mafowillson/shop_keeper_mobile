import 'package:flutter/foundation.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/offline/connectivity_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/features/products/data/datasources/product_local_datasource.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/domain/usecases/deactivate_product_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/get_products_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/save_product_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/search_products_usecase.dart';

// Registered manually in injection.dart — constructor includes cache deps.
class ProductProvider extends ChangeNotifier {
  final GetProductsUseCase _getProducts;
  final SaveProductUseCase _saveProduct;
  final DeactivateProductUseCase _deactivateProduct;
  final SearchProductsUseCase _searchProducts;
  final ProductLocalDataSource _local;
  final CacheMetadataService _metadata;
  final ConnectivityService _connectivity;

  ProductProvider(
    this._getProducts,
    this._saveProduct,
    this._deactivateProduct,
    this._searchProducts,
    this._local,
    this._metadata,
    this._connectivity,
  );

  List<Product> _products = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _metadata.getTimestamp(HiveBoxes.products);

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList()..sort();
    return cats;
  }

  // ── Stale-while-revalidate load ───────────────────────────────────────────

  Future<void> loadProducts(String shopId, {String? category}) async {
    _errorMessage = null;

    // Step 1: serve cache immediately — no spinner if data exists.
    final cached = _local.getProducts(shopId: shopId);
    if (cached.isNotEmpty) {
      _products = cached.map((m) => m.toEntity()).toList();
      _isLoading = false;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    // Step 2: background refresh when online.
    if (_connectivity.isOnline) {
      _isRefreshing = cached.isNotEmpty;
      if (_isRefreshing) notifyListeners();
      final result =
          await _getProducts(shopId: shopId, category: category).run();
      result.fold(
        (f) {
          if (_products.isEmpty) _errorMessage = f.message;
        },
        (fresh) => _products = fresh,
      );
      _isRefreshing = false;
    }

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

    // Search local first for instant results.
    final localResults = _local
        .getProducts(shopId: shopId)
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
    if (localResults.isNotEmpty) {
      _products = localResults.map((m) => m.toEntity()).toList();
      _isLoading = false;
      notifyListeners();
    }

    if (_connectivity.isOnline) {
      final result = await _searchProducts(query, shopId: shopId).run();
      result.fold(
        (f) {
          if (_products.isEmpty) _errorMessage = f.message;
        },
        (fresh) => _products = fresh,
      );
    }
    _isLoading = false;
    notifyListeners();
  }

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
        final idx = _products.indexWhere((x) => x.id == p.id);
        if (idx >= 0) {
          _products[idx] = p;
        } else {
          _products = [p, ..._products];
        }
        _metadata.saveTimestamp(HiveBoxes.products);
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
        _metadata.saveTimestamp(HiveBoxes.products);
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
