import 'package:shopkeeper/features/products/data/models/product_model.dart';

abstract class IProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    required String shopId,
    String? search,
    String? category,
    int page = 1,
    int pageSize = 50,
  });
  Future<ProductModel> getProductById(String id);
  Future<ProductModel> createProduct(ProductModel model);
  Future<ProductModel> updateProduct(String id, ProductModel model);
  Future<void> deactivateProduct(String id);
}
