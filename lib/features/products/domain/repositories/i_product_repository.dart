import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';

abstract class IProductRepository {
  TaskEither<Failure, List<Product>> getProducts({required String shopId, String? search, String? category});
  TaskEither<Failure, Product> getProductById(String id);
  TaskEither<Failure, Product> saveProduct(Product product);
  TaskEither<Failure, Unit> deactivateProduct(String id);
  TaskEither<Failure, List<Product>> searchProducts(String query, {required String shopId});
  TaskEither<Failure, Unit> decrementStock(String productId, int qty);
}
