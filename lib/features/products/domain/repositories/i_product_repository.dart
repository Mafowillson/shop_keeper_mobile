import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';

abstract class IProductRepository {
  TaskEither<Failure, List<Product>> getProducts();
  TaskEither<Failure, Product> getProductById(String id);
  TaskEither<Failure, Unit> saveProduct(Product product);
  TaskEither<Failure, Unit> deactivateProduct(String id);
  TaskEither<Failure, List<Product>> searchProducts(String query);
  TaskEither<Failure, Unit> decrementStock(String productId, int qty);
}
