import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';

@lazySingleton
class GetProductByIdUseCase {
  final IProductRepository _repository;

  const GetProductByIdUseCase(this._repository);

  TaskEither<Failure, Product> call(String id) => _repository.getProductById(id);
}
