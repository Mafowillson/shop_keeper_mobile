import 'dart:convert';
import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:shopkeeper/core/config/app_config.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/core/offline/connectivity_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/core/offline/sync_log_entry.dart';
import 'package:shopkeeper/features/products/data/datasources/product_local_datasource.dart';
import 'package:shopkeeper/features/sales/data/datasources/i_sale_remote_datasource.dart';
import 'package:shopkeeper/features/sales/data/datasources/sale_local_datasource.dart';
import 'package:shopkeeper/features/sales/data/models/sale_item_model.dart';
import 'package:shopkeeper/features/sales/data/models/sale_model.dart';
import 'package:shopkeeper/features/sales/domain/entities/cart_item.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/domain/repositories/i_sale_repository.dart';

// Registered manually in injection.dart.
class SaleRepositoryImpl implements ISaleRepository {
  final ISaleRemoteDataSource _remote;
  final SaleLocalDataSource _local;
  final ProductLocalDataSource _productLocal;
  final ConnectivityService _connectivity;

  const SaleRepositoryImpl(
    this._remote,
    this._local,
    this._productLocal,
    this._connectivity,
  );

  @override
  TaskEither<Failure, List<Sale>> getSales({required String shopId}) =>
      TaskEither.tryCatch(
        () async {
          if (_connectivity.isOnline) {
            try {
              final models = await _remote.getSales(shopId: shopId);
              await _local.cacheSales(models);
              // Merge with any locally-created offline sales.
              final offline = _local
                  .getSales(shopId: shopId)
                  .where((s) => s.id.startsWith('offline_'))
                  .toList();
              final all = [...models, ...offline];
              all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return all.map((m) => m.toEntity()).toList();
            } catch (_) {}
          }
          return _local
              .getSales(shopId: shopId)
              .map((m) => m.toEntity())
              .toList();
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, Sale> getSaleById(String id) => TaskEither.tryCatch(
        () async {
          if (_connectivity.isOnline && !id.startsWith('offline_')) {
            try {
              final model = await _remote.getSaleById(id);
              await _local.saveSale(model);
              return model.toEntity();
            } catch (_) {}
          }
          final cached = _local.getSaleById(id);
          if (cached == null) throw Exception('Sale not found offline.');
          return cached.toEntity();
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, Sale> recordSale({
    required String shopId,
    required List<CartItem> cartItems,
    required double paidAmount,
    required bool isCredit,
    String? customerId,
  }) =>
      TaskEither.tryCatch(
        () async {
          if (_connectivity.isOnline) {
            final items = cartItems
                .map((c) => {
                      'product_id': c.product.id,
                      'unit': c.unit.name,
                      'quantity': c.quantity,
                    })
                .toList();

            final body = <String, dynamic>{
              'shop_id': shopId,
              'items': items,
              'paid_amount': paidAmount,
              'is_credit': isCredit,
            };
            if (customerId != null && customerId.isNotEmpty) {
              body['customer_id'] = customerId;
            }

            final model = await _remote.createSale(body);
            await _local.saveSale(model);
            // Keep local stocks accurate after a confirmed sale.
            for (final item in cartItems) {
              await _productLocal.decrementStock(
                item.product.id,
                item.quantity * item.unit.quantityInBase,
              );
            }
            return model.toEntity();
          }

          // ── Offline path ──────────────────────────────────────────────────
          final totalAmount =
              cartItems.fold<double>(0.0, (sum, item) => sum + item.subtotal);
          final dueAmount = (totalAmount - paidAmount).clamp(0.0, totalAmount);
          final tempId = _generateOfflineId();

          final saleItems = cartItems
              .map((c) => SaleItemModel(
                    productId: c.product.id,
                    unit: c.unit.name,
                    quantity: c.quantity,
                    unitPrice: c.unit.price,
                    totalPrice: c.subtotal,
                  ))
              .toList();

          final saleModel = SaleModel(
            id: tempId,
            shopId: shopId,
            ownerId: '',
            customerId: customerId,
            items: saleItems,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            dueAmount: dueAmount,
            isCredit: isCredit,
            isPaid: dueAmount <= 0,
            createdAt: DateTime.now(),
          );

          // Sync log payload — the exact body we'll send to POST /sales.
          final syncPayload = <String, dynamic>{
            'shop_id': shopId,
            'items': cartItems
                .map((c) => {
                      'product_id': c.product.id,
                      'unit': c.unit.name,
                      'quantity': c.quantity,
                    })
                .toList(),
            'paid_amount': paidAmount,
            'is_credit': isCredit,
          };
          if (customerId != null && customerId.isNotEmpty) {
            syncPayload['customer_id'] = customerId;
          }

          await _local.saveSale(saleModel);
          await _writeSyncLogEntry(SyncLogEntry(
            id: 'sync_$tempId',
            deviceId: AppConfig.deviceId,
            entityType: SyncEntityType.sale,
            operationType: SyncOperationType.create,
            payload: syncPayload,
            status: SyncEntryStatus.pending,
            timestamp: DateTime.now(),
          ));

          // Deduct from local stock so subsequent offline sales are accurate.
          for (final item in cartItems) {
            await _productLocal.decrementStock(
              item.product.id,
              item.quantity * item.unit.quantityInBase,
            );
          }

          return saleModel.toEntity();
        },
        (e, _) => ServerFailure('$e'),
      );

  // ── Helpers ───────────────────────────────────────────────────────────────

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
