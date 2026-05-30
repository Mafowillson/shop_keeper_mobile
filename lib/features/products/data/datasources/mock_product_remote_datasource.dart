import 'package:injectable/injectable.dart';
import 'package:shopkeeper/features/products/data/datasources/i_product_remote_datasource.dart';
import 'package:shopkeeper/features/products/data/models/product_model.dart';

@LazySingleton(as: IProductRemoteDataSource)
class MockProductRemoteDataSource implements IProductRemoteDataSource {
  @override
  Future<List<ProductModel>> getProducts() async {
    // Return mock data
    return [];
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    throw Exception('Product not found');
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    // Mock implementation - would send to server
  }

  @override
  Future<void> deactivateProduct(String id) async {
    // Mock implementation - would send to server
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    // Return mock data
    return [];
  }

  @override
  Future<void> decrementStock(String productId, int qty) async {
    // Mock implementation - would send to server
  }
}
