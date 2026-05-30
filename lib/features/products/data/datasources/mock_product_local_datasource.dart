import 'package:injectable/injectable.dart';
import 'package:shopkeeper/features/products/data/datasources/i_product_local_datasource.dart';
import 'package:shopkeeper/features/products/data/models/product_model.dart';

@LazySingleton(as: IProductLocalDataSource)
class MockProductLocalDataSource implements IProductLocalDataSource {
  final List<ProductModel> _products = [];

  @override
  Future<List<ProductModel>> getProducts() async {
    return _products;
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _products[index] = product;
    } else {
      _products.add(product);
    }
  }

  @override
  Future<void> deactivateProduct(String id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final product = _products[index];
      _products[index] = product.copyWith(isActive: false);
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<void> decrementStock(String productId, int qty) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final product = _products[index];
      final newStock =
          (product.stockQty - qty).clamp(0, double.infinity).toInt();
      _products[index] = product.copyWith(stockQty: newStock);
    }
  }
}
