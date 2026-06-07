import 'dart:convert';
import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:shopkeeper/core/config/app_config.dart';
import 'package:shopkeeper/core/enums/debt_type.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/core/offline/connectivity_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/core/offline/sync_log_entry.dart';
import 'package:shopkeeper/features/debts/data/datasources/debt_local_datasource.dart';
import 'package:shopkeeper/features/debts/data/datasources/i_debt_remote_datasource.dart';
import 'package:shopkeeper/features/debts/data/models/customer_model.dart';
import 'package:shopkeeper/features/debts/data/models/debt_record_model.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/domain/entities/debt_record.dart';
import 'package:shopkeeper/features/debts/domain/repositories/i_debt_repository.dart';

// Registered manually in injection.dart.
class DebtRepositoryImpl implements IDebtRepository {
  final IDebtRemoteDataSource _remote;
  final DebtLocalDataSource _local;
  final ConnectivityService _connectivity;

  const DebtRepositoryImpl(this._remote, this._local, this._connectivity);

  @override
  TaskEither<Failure, List<Customer>> getCustomers(
          {required String shopId, bool? hasDebt}) =>
      TaskEither.tryCatch(
        () async {
          if (_connectivity.isOnline) {
            try {
              final models =
                  await _remote.getCustomers(shopId: shopId, hasDebt: hasDebt);
              // Cache only unfiltered results to avoid partial cache.
              if (hasDebt == null) {
                await _local.cacheCustomers(models);
              }
              // Merge with any offline-created customers.
              final offlineExtra = _local
                  .getCustomers(shopId: shopId, hasDebt: hasDebt)
                  .where((c) => c.id.startsWith('offline_'))
                  .toList();
              return [...models, ...offlineExtra]
                  .map((m) => m.toEntity())
                  .toList();
            } catch (_) {}
          }
          return _local
              .getCustomers(shopId: shopId, hasDebt: hasDebt)
              .map((m) => m.toEntity())
              .toList();
        },
        (e, _) => ServerFailure(e.toString()),
      );

  @override
  TaskEither<Failure, Customer> getCustomerById(String id) =>
      TaskEither.tryCatch(
        () async {
          if (_connectivity.isOnline && !id.startsWith('offline_')) {
            try {
              final model = await _remote.getCustomerById(id);
              await _local.saveCustomer(model);
              return model.toEntity();
            } catch (_) {}
          }
          final cached = _local.getCustomerById(id);
          if (cached == null) throw Exception('Customer not found offline.');
          return cached.toEntity();
        },
        (e, _) => ServerFailure(e.toString()),
      );

  @override
  TaskEither<Failure, Customer> createCustomer(
          {required String shopId, required String name, String? phone}) =>
      TaskEither.tryCatch(
        () async {
          if (_connectivity.isOnline) {
            final model = await _remote.createCustomer(
                shopId: shopId, name: name, phone: phone);
            await _local.saveCustomer(model);
            return model.toEntity();
          }

          // ── Offline path ──────────────────────────────────────────────────
          final tempId = _generateOfflineId();
          final customer = CustomerModel(
            id: tempId,
            shopId: shopId,
            name: name,
            phone: phone ?? '',
            totalDebt: 0,
            createdAt: DateTime.now(),
          );
          await _local.saveCustomer(customer);
          await _writeSyncLogEntry(SyncLogEntry(
            id: 'sync_$tempId',
            deviceId: AppConfig.deviceId,
            entityType: SyncEntityType.customer,
            operationType: SyncOperationType.create,
            payload: {
              'shop_id': shopId,
              'name': name,
              'phone': phone ?? '',
            },
            status: SyncEntryStatus.pending,
            timestamp: DateTime.now(),
          ));
          return customer.toEntity();
        },
        (e, _) => ServerFailure(e.toString()),
      );

  @override
  TaskEither<Failure, List<DebtRecord>> getDebtHistory(String customerId) =>
      TaskEither.tryCatch(
        () async {
          if (_connectivity.isOnline && !customerId.startsWith('offline_')) {
            try {
              final models = await _remote.getDebtHistory(customerId);
              return models.map((m) => m.toEntity()).toList();
            } catch (_) {}
          }
          return _local
              .getDebtHistory(customerId)
              .map((m) => m.toEntity())
              .toList();
        },
        (e, _) => ServerFailure(e.toString()),
      );

  @override
  TaskEither<Failure, Unit> recordPayment(
          String customerId, double amount, String? note) =>
      TaskEither.tryCatch(
        () async {
          if (_connectivity.isOnline && !customerId.startsWith('offline_')) {
            await _remote.recordPayment(customerId, amount, note);
            // Refresh customer locally after confirmed payment.
            try {
              final updated = await _remote.getCustomerById(customerId);
              await _local.saveCustomer(updated);
            } catch (_) {}
            return unit;
          }

          // ── Offline path ──────────────────────────────────────────────────
          final existing = _local.getCustomerById(customerId);
          if (existing == null) {
            throw Exception('Customer not found offline.');
          }
          final newDebt =
              (existing.totalDebt - amount).clamp(0.0, existing.totalDebt);
          final updatedCustomer = CustomerModel(
            id: existing.id,
            shopId: existing.shopId,
            name: existing.name,
            phone: existing.phone,
            totalDebt: newDebt,
            createdAt: existing.createdAt,
          );
          await _local.saveCustomer(updatedCustomer);

          final tempId = _generateOfflineId();
          final record = DebtRecordModel(
            id: tempId,
            customerId: customerId,
            type: DebtType.payment,
            amount: amount,
            balanceAfter: newDebt,
            note: note,
            recordedAt: DateTime.now(),
          );
          await _local.saveDebtRecord(record);

          await _writeSyncLogEntry(SyncLogEntry(
            id: 'sync_$tempId',
            deviceId: AppConfig.deviceId,
            entityType: SyncEntityType.debtRecord,
            operationType: SyncOperationType.payment,
            payload: {
              'customer_id': customerId,
              'amount': amount,
              if (note != null && note.isNotEmpty) 'note': note,
            },
            status: SyncEntryStatus.pending,
            timestamp: DateTime.now(),
          ));
          return unit;
        },
        (e, _) => ServerFailure(e.toString()),
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
