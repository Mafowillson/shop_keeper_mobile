import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/products/data/datasources/i_product_remote_datasource.dart';
import 'package:shopkeeper/features/products/data/models/product_model.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';

@LazySingleton(as: IProductRepository)
class ProductRepositoryImpl implements IProductRepository {
  final IProductRemoteDataSource _remote;

  const ProductRepositoryImpl(this._remote);

  @override
  TaskEither<Failure, List<Product>> getProducts({
    required String shopId,
    String? search,
    String? category,
  }) =>
      TaskEither.tryCatch(
        () async {
          final models = await _remote.getProducts(
            shopId: shopId,
            search: search,
            category: category,
          );
          return models.map((m) => m.toEntity()).toList();
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, Product> getProductById(String id) => TaskEither.tryCatch(
        () async {
          final model = await _remote.getProductById(id);
          return model.toEntity();
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, Product> saveProduct(Product product) =>
      TaskEither.tryCatch(
        () async {
          final model = ProductModel.fromEntity(product);
          final saved = product.id.isEmpty
              ? await _remote.createProduct(model)
              : await _remote.updateProduct(product.id, model);
          return saved.toEntity();
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, Unit> deactivateProduct(String id) => TaskEither.tryCatch(
        () async {
          await _remote.deactivateProduct(id);
          return unit;
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, List<Product>> searchProducts(
    String query, {
    required String shopId,
  }) =>
      TaskEither.tryCatch(
        () async {
          final models =
              await _remote.getProducts(shopId: shopId, search: query);
          return models.map((m) => m.toEntity()).toList();
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, Unit> decrementStock(String productId, int qty) =>
      // Stock is decremented server-side when a sale is recorded via /sales.
      TaskEither.right(unit);
}
