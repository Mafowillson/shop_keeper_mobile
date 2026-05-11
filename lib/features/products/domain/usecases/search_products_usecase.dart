import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';

@lazySingleton
class SearchProductsUseCase {
  final IProductRepository _repository;

  const SearchProductsUseCase(this._repository);

  TaskEither<Failure, List<Product>> call(String query) =>
      _repository.searchProducts(query);
}
