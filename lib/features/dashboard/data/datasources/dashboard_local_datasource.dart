import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/features/dashboard/data/models/dashboard_stats_model.dart';

class DashboardLocalDataSource {
  final CacheMetadataService _metadata;

  DashboardLocalDataSource(this._metadata);

  Box get _box => Hive.box(HiveBoxes.dashboard);

  String _key(String shopId) => 'stats:$shopId';

  DashboardStatsModel? getStats(String shopId) {
    final raw = _box.get(_key(shopId)) as String?;
    if (raw == null) return null;
    try {
      return DashboardStatsModel.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveStats(DashboardStatsModel model, String shopId) async {
    await _box.put(_key(shopId), jsonEncode(model.toJson()));
    await _metadata.saveTimestamp(HiveBoxes.dashboard);
  }

  Future<void> invalidate({String? shopId}) async {
    if (shopId == null || shopId.isEmpty) {
      await _box.clear();
    } else {
      await _box.delete(_key(shopId));
    }
    await _metadata.clearTimestamp(HiveBoxes.dashboard);
  }

  bool get isEmpty => _box.isEmpty;
}
