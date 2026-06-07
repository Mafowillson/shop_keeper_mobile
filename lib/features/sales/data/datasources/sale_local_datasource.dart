import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/features/sales/data/models/sale_model.dart';

class SaleLocalDataSource {
  final CacheMetadataService metadata;

  SaleLocalDataSource(this.metadata);

  Box get _box => Hive.box(HiveBoxes.sales);

  // ── Reads ─────────────────────────────────────────────────────────────────

  List<SaleModel> getSales({required String shopId}) {
    return _box.values
        .whereType<String>()
        .map((raw) {
          try {
            return SaleModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<SaleModel>()
        .where((s) => s.shopId == shopId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  SaleModel? getSaleById(String id) {
    final raw = _box.get(id) as String?;
    if (raw == null) return null;
    try {
      return SaleModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  Future<void> saveSale(SaleModel sale) async {
    await _box.put(sale.id, jsonEncode(sale.toJson()));
    await metadata.saveTimestamp(HiveBoxes.sales);
  }

  /// Caches a fresh batch from the server.  Preserves offline temp entries.
  Future<void> cacheSales(List<SaleModel> sales) async {
    if (sales.isEmpty) return;
    final serverEntries = {
      for (final s in sales)
        if (!s.id.startsWith('offline_')) s.id: jsonEncode(s.toJson()),
    };
    await _box.putAll(serverEntries);
    await metadata.saveTimestamp(HiveBoxes.sales);
  }

  Future<void> removeTempEntry(String tempId) async {
    if (_box.containsKey(tempId)) await _box.delete(tempId);
  }

  // ── Cache control ─────────────────────────────────────────────────────────

  Future<void> invalidate() async {
    await _box.clear();
    await metadata.clearTimestamp(HiveBoxes.sales);
  }

  bool get isEmpty => _box.isEmpty;
}
