import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';

@lazySingleton
class GetProductsUseCase {
  final IProductRepository _repository;

  const GetProductsUseCase(this._repository);

  TaskEither<Failure, List<Product>> call() => _repository.getProducts();
}
