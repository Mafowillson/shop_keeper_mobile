import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';

@lazySingleton
class RestockProductUseCase {
  final IProductRepository _repository;
  const RestockProductUseCase(this._repository);

  TaskEither<Failure, Unit> call(String productId, int newQty) =>
      _repository.restockProduct(productId, newQty);
}
