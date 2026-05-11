import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';

@lazySingleton
class DeactivateProductUseCase {
  final IProductRepository _repository;

  const DeactivateProductUseCase(this._repository);

  TaskEither<Failure, Unit> call(String id) => _repository.deactivateProduct(id);
}
