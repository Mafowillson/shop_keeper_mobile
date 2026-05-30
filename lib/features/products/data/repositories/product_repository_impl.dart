import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/products/data/datasources/i_product_local_datasource.dart';
import 'package:shopkeeper/features/products/data/datasources/i_product_remote_datasource.dart';
import 'package:shopkeeper/features/products/data/models/product_model.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';

@LazySingleton(as: IProductRepository)
class ProductRepositoryImpl implements IProductRepository {
  final IProductRemoteDataSource _remote;
  final IProductLocalDataSource _local;

  ProductRepositoryImpl(this._remote, this._local);

  @override
  TaskEither<Failure, List<Product>> getProducts() => TaskEither.tryCatch(
        () async {
          final models = await _local.getProducts();
          return models.map((m) => m.toEntity()).toList();
        },
        (e, _) => ServerFailure('Failed to fetch products'),
      );

  @override
  TaskEither<Failure, Product> getProductById(String id) => TaskEither.tryCatch(
        () async {
          final model = await _local.getProductById(id);
          if (model == null) {
            throw Exception('Product not found');
          }
          return model.toEntity();
        },
        (e, _) => ServerFailure('Failed to fetch product'),
      );

  @override
  TaskEither<Failure, Unit> saveProduct(Product product) => TaskEither.tryCatch(
        () async {
          final model = ProductModel.fromEntity(product);
          await _local.saveProduct(model);
          await _remote.saveProduct(model);
          return unit;
        },
        (e, _) => ServerFailure('Failed to save product'),
      );

  @override
  TaskEither<Failure, Unit> deactivateProduct(String id) => TaskEither.tryCatch(
        () async {
          await _local.deactivateProduct(id);
          await _remote.deactivateProduct(id);
          return unit;
        },
        (e, _) => ServerFailure('Failed to deactivate product'),
      );

  @override
  TaskEither<Failure, List<Product>> searchProducts(String query) =>
      TaskEither.tryCatch(
        () async {
          final models = await _local.searchProducts(query);
          return models.map((m) => m.toEntity()).toList();
        },
        (e, _) => ServerFailure('Failed to search products'),
      );

  @override
  TaskEither<Failure, Unit> decrementStock(String productId, int qty) =>
      TaskEither.tryCatch(
        () async {
          await _local.decrementStock(productId, qty);
          await _remote.decrementStock(productId, qty);
          return unit;
        },
        (e, _) => ServerFailure('Failed to update stock'),
      );
}
