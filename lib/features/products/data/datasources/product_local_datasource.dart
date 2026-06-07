import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/features/products/data/models/product_model.dart';

class ProductLocalDataSource {
  final CacheMetadataService metadata;

  ProductLocalDataSource(this.metadata);

  Box get _box => Hive.box(HiveBoxes.products);

  // ── Reads (synchronous — Hive is in-memory) ───────────────────────────────

  List<ProductModel> getProducts({required String shopId}) {
    return _box.values
        .whereType<String>()
        .map((raw) {
          try {
            return ProductModel.fromJson(
                jsonDecode(raw) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<ProductModel>()
        .where((p) => p.shopId == shopId && p.isActive)
        .toList();
  }

  ProductModel? getProductById(String id) {
    final raw = _box.get(id) as String?;
    if (raw == null) return null;
    try {
      return ProductModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  /// Replaces the entire cached product list for a shop (used during pull).
  Future<void> cacheProducts(List<ProductModel> products) async {
    if (products.isEmpty) return;
    final shopId = products.first.shopId;
    final keysToDelete = _box.keys.where((k) {
      final raw = _box.get(k) as String?;
      if (raw == null) return false;
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return json['shop_id'] == shopId;
      } catch (_) {
        return false;
      }
    }).toList();
    await _box.deleteAll(keysToDelete);
    final entries = {for (final p in products) p.id: jsonEncode(p.toJson())};
    await _box.putAll(entries);
    await metadata.saveTimestamp(HiveBoxes.products);
  }

  Future<void> saveProduct(ProductModel product) async {
    await _box.put(product.id, jsonEncode(product.toJson()));
    await metadata.saveTimestamp(HiveBoxes.products);
  }

  Future<void> decrementStock(String productId, int totalBaseUnits) async {
    final raw = _box.get(productId) as String?;
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final current = json['stock_qty'] as int? ?? 0;
      json['stock_qty'] = (current - totalBaseUnits).clamp(0, current);
      await _box.put(productId, jsonEncode(json));
    } catch (_) {}
  }

  Future<void> markInactive(String productId) async {
    final raw = _box.get(productId) as String?;
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      json['is_active'] = false;
      await _box.put(productId, jsonEncode(json));
    } catch (_) {}
  }

  // ── Cache control ─────────────────────────────────────────────────────────

  Future<void> invalidate() async {
    await _box.clear();
    await metadata.clearTimestamp(HiveBoxes.products);
  }

  bool get isEmpty => _box.isEmpty;
}
