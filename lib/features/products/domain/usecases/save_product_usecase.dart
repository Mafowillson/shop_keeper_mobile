import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';

@lazySingleton
class SaveProductUseCase {
  final IProductRepository _repository;

  const SaveProductUseCase(this._repository);

  TaskEither<Failure, Product> call(Product product) {
    if (product.name.trim().isEmpty) {
      return TaskEither.left(const ValidationFailure('Name is required.'));
    }
    if (product.retailPrice <= 0) {
      return TaskEither.left(const ValidationFailure('Retail price must be > 0.'));
    }
    if (product.cartonQty > 1 && product.cartonPrice < product.retailPrice) {
      return TaskEither.left(
        const ValidationFailure('Carton price must be >= retail price.'),
      );
    }
    return _repository.saveProduct(product);
  }
}
