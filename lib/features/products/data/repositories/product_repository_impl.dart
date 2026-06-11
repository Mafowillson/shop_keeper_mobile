import 'dart:convert';
import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/config/app_config.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/core/offline/connectivity_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/core/offline/sync_log_entry.dart';
import 'package:shopkeeper/features/products/data/datasources/i_product_remote_datasource.dart';
import 'package:shopkeeper/features/products/data/datasources/product_local_datasource.dart';
import 'package:shopkeeper/features/products/data/models/product_model.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';
import 'package:hive/hive.dart';

// Registered manually in injection.dart — no @LazySingleton to avoid
// conflict with the offline constructor that build_runner doesn't know about.
class ProductRepositoryImpl implements IProductRepository {
  final IProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;
  final ConnectivityService _connectivity;

  const ProductRepositoryImpl(this._remote, this._local, this._connectivity);

  @override
  TaskEither<Failure, List<Product>> getProducts({
    required String shopId,
    String? search,
    String? category,
  }) =>
      TaskEither.tryCatch(
        () async {
          if (_connectivity.isOnline) {
            try {
              final models = await _remote.getProducts(
                shopId: shopId,
                search: search,
                category: category,
              );
              // Refresh cache on successful fetch.
              if (search == null && category == null) {
                await _local.cacheProducts(models);
              }
              return models.map((m) => m.toEntity()).toList();
            } catch (_) {
              // Fall through to local cache on transient network errors.
            }
          }
          final cached = _local.getProducts(shopId: shopId);
          if (cached.isEmpty && !_connectivity.isOnline) {
            throw Exception('No cached products available offline.');
          }
          return _filterLocal(cached, search: search, category: category)
              .map((m) => m.toEntity())
              .toList();
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, Product> getProductById(String id) => TaskEither.tryCatch(
        () async {
          if (_connectivity.isOnline) {
            try {
              final model = await _remote.getProductById(id);
              await _local.saveProduct(model);
              return model.toEntity();
            } catch (_) {}
          }
          final cached = _local.getProductById(id);
          if (cached == null) throw Exception('Product not found offline.');
          return cached.toEntity();
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, Product> saveProduct(Product product) =>
      TaskEither.tryCatch(
        () async {
          if (_connectivity.isOnline) {
            final model = ProductModel.fromEntity(product);
            final saved = product.id.isEmpty
                ? await _remote.createProduct(model)
                : await _remote.updateProduct(product.id, model);
            await _local.saveProduct(saved);
            return saved.toEntity();
          }
          // Offline path — queue in sync log and save locally.
          final isCreate = product.id.isEmpty;
          final tempId = isCreate ? _generateOfflineId() : product.id;
          final offlineProduct = ProductModel.fromEntity(
            product.copyWith(),
          );
          // Replace id field since ProductModel uses entity's id directly.
          final productWithId = ProductModel(
            id: tempId,
            shopId: offlineProduct.shopId,
            name: offlineProduct.name,
            category: offlineProduct.category,
            baseUnit: offlineProduct.baseUnit,
            units: offlineProduct.units,
            stockQty: offlineProduct.stockQty,
            lowStockThreshold: offlineProduct.lowStockThreshold,
            isActive: offlineProduct.isActive,
          );
          await _local.saveProduct(productWithId);
          await _writeSyncLogEntry(SyncLogEntry(
            id: 'sync_$tempId',
            deviceId: AppConfig.deviceId,
            entityType: SyncEntityType.product,
            operationType:
                isCreate ? SyncOperationType.create : SyncOperationType.update,
            payload: isCreate
                ? productWithId.toCreateRequest()
                : productWithId.toUpdateRequest()
              ..['product_id'] = tempId,
            status: SyncEntryStatus.pending,
            timestamp: DateTime.now(),
          ));
          return productWithId.toEntity();
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, Unit> deactivateProduct(String id) => TaskEither.tryCatch(
        () async {
          if (_connectivity.isOnline) {
            await _remote.deactivateProduct(id);
          } else {
            await _writeSyncLogEntry(SyncLogEntry(
              id: 'sync_del_$id',
              deviceId: AppConfig.deviceId,
              entityType: SyncEntityType.product,
              operationType: SyncOperationType.delete,
              payload: {'product_id': id},
              status: SyncEntryStatus.pending,
              timestamp: DateTime.now(),
            ));
          }
          await _local.markInactive(id);
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
          if (_connectivity.isOnline) {
            try {
              final models =
                  await _remote.getProducts(shopId: shopId, search: query);
              return models.map((m) => m.toEntity()).toList();
            } catch (_) {}
          }
          final cached = _local.getProducts(shopId: shopId);
          return _filterLocal(cached, search: query)
              .map((m) => m.toEntity())
              .toList();
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, Unit> decrementStock(String productId, int qty) =>
      TaskEither.right(unit);

  @override
  TaskEither<Failure, Unit> restockProduct(String productId, int newQty) =>
      TaskEither.tryCatch(
        () async {
          if (_connectivity.isOnline) {
            await _remote.restockProduct(productId, newQty);
          } else {
            await _writeSyncLogEntry(SyncLogEntry(
              id: 'sync_restock_${productId}_${DateTime.now().millisecondsSinceEpoch}',
              deviceId: AppConfig.deviceId,
              entityType: SyncEntityType.product,
              operationType: SyncOperationType.update,
              payload: {'product_id': productId, 'stock_qty': newQty},
              status: SyncEntryStatus.pending,
              timestamp: DateTime.now(),
            ));
          }
          // Optimistically update local cache regardless of what the backend
          // response contains — ensures UI reflects the intended new stock.
          final cached = _local.getProductById(productId);
          if (cached != null) {
            await _local.saveProduct(ProductModel(
              id: cached.id,
              shopId: cached.shopId,
              name: cached.name,
              category: cached.category,
              baseUnit: cached.baseUnit,
              units: cached.units,
              stockQty: newQty,
              lowStockThreshold: cached.lowStockThreshold,
              isActive: cached.isActive,
            ));
          }
          return unit;
        },
        (e, _) => ServerFailure('$e'),
      );

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<ProductModel> _filterLocal(
    List<ProductModel> list, {
    String? search,
    String? category,
  }) {
    return list.where((p) {
      if (category != null && category.isNotEmpty && p.category != category) {
        return false;
      }
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        if (!p.name.toLowerCase().contains(q) &&
            !p.category.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> _writeSyncLogEntry(SyncLogEntry entry) async {
    final box = Hive.box(HiveBoxes.syncLog);
    await box.put(entry.id, jsonEncode(entry.toJson()));
  }

  String _generateOfflineId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(0xFFFF).toRadixString(16).padLeft(4, '0');
    return 'offline_${ts.toRadixString(36)}_$rand';
  }
}
