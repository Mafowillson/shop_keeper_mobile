import 'package:shopkeeper/features/products/data/models/product_model.dart';

abstract class IProductLocalDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel?> getProductById(String id);
  Future<void> saveProduct(ProductModel product);
  Future<void> deactivateProduct(String id);
  Future<List<ProductModel>> searchProducts(String query);
  Future<void> decrementStock(String productId, int qty);
}
