import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
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

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getProducts().run();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (_) {
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
