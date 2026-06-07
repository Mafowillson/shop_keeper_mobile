import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/features/debts/data/models/customer_model.dart';
import 'package:shopkeeper/features/debts/data/models/debt_record_model.dart';

class DebtLocalDataSource {
  final CacheMetadataService metadata;

  DebtLocalDataSource(this.metadata);

  Box get _customersBox => Hive.box(HiveBoxes.customers);
  Box get _debtBox => Hive.box(HiveBoxes.debtRecords);

  // ── Customer reads ────────────────────────────────────────────────────────

  List<CustomerModel> getCustomers({required String shopId, bool? hasDebt}) {
    return _customersBox.values
        .whereType<String>()
        .map((raw) {
          try {
            return CustomerModel.fromJson(
                jsonDecode(raw) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<CustomerModel>()
        .where((c) {
          if (c.shopId != shopId) return false;
          if (hasDebt == true) return c.totalDebt > 0;
          if (hasDebt == false) return c.totalDebt <= 0;
          return true;
        })
        .toList();
  }

  CustomerModel? getCustomerById(String id) {
    final raw = _customersBox.get(id) as String?;
    if (raw == null) return null;
    try {
      return CustomerModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Customer writes ───────────────────────────────────────────────────────

  Future<void> saveCustomer(CustomerModel customer) async {
    await _customersBox.put(customer.id, jsonEncode(customer.toJson()));
    await metadata.saveTimestamp(HiveBoxes.customers);
  }

  Future<void> cacheCustomers(List<CustomerModel> customers) async {
    if (customers.isEmpty) return;
    final shopId = customers.first.shopId;
    final keysToDelete = _customersBox.keys.where((k) {
      final raw = _customersBox.get(k) as String?;
      if (raw == null) return false;
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return json['shop_id'] == shopId &&
            !(k as String).startsWith('offline_');
      } catch (_) {
        return false;
      }
    }).toList();
    await _customersBox.deleteAll(keysToDelete);
    final entries = {
      for (final c in customers) c.id: jsonEncode(c.toJson()),
    };
    await _customersBox.putAll(entries);
    await metadata.saveTimestamp(HiveBoxes.customers);
  }

  Future<void> removeTempCustomer(String tempId) async {
    if (_customersBox.containsKey(tempId)) {
      await _customersBox.delete(tempId);
    }
    final staleKeys = _debtBox.keys.where((k) {
      final raw = _debtBox.get(k) as String?;
      if (raw == null) return false;
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return json['customer_id'] == tempId;
      } catch (_) {
        return false;
      }
    }).toList();
    if (staleKeys.isNotEmpty) await _debtBox.deleteAll(staleKeys);
  }

  // ── Debt record reads ─────────────────────────────────────────────────────

  List<DebtRecordModel> getDebtHistory(String customerId) {
    return _debtBox.values
        .whereType<String>()
        .map((raw) {
          try {
            return DebtRecordModel.fromJson(
                jsonDecode(raw) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<DebtRecordModel>()
        .where((r) => r.customerId == customerId)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  // ── Debt record writes ────────────────────────────────────────────────────

  Future<void> saveDebtRecord(DebtRecordModel record) async {
    await _debtBox.put(record.id, jsonEncode(record.toJson()));
    await metadata.saveTimestamp(HiveBoxes.debtRecords);
  }

  // ── Cache control ─────────────────────────────────────────────────────────

  Future<void> invalidateCustomers() async {
    await _customersBox.clear();
    await metadata.clearTimestamp(HiveBoxes.customers);
  }

  Future<void> invalidateDebtRecords() async {
    await _debtBox.clear();
    await metadata.clearTimestamp(HiveBoxes.debtRecords);
  }

  bool get isCustomersEmpty => _customersBox.isEmpty;
}
