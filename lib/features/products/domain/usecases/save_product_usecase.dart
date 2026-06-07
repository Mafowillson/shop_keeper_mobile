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
    if (product.units.isEmpty) {
      return TaskEither.left(
          const ValidationFailure('At least one unit is required.'));
    }
    final baseUnits = product.units.where((u) => u.quantityInBase == 1);
    if (baseUnits.isEmpty) {
      return TaskEither.left(const ValidationFailure(
          'Exactly one unit must have quantity-in-base = 1.'));
    }
    if (baseUnits.length > 1) {
      return TaskEither.left(const ValidationFailure(
          'Only one unit can have quantity-in-base = 1.'));
    }
    if (product.units.any((u) => u.price <= 0)) {
      return TaskEither.left(const ValidationFailure(
          'All unit prices must be greater than zero.'));
    }
    return _repository.saveProduct(product);
  }
}
