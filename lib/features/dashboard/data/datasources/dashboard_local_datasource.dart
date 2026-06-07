import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/features/dashboard/data/models/dashboard_stats_model.dart';

class DashboardLocalDataSource {
  final CacheMetadataService _metadata;

  DashboardLocalDataSource(this._metadata);

  Box get _box => Hive.box(HiveBoxes.dashboard);

  static const _key = 'stats';

  DashboardStatsModel? getStats() {
    final raw = _box.get(_key) as String?;
    if (raw == null) return null;
    try {
      return DashboardStatsModel.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveStats(DashboardStatsModel model) async {
    await _box.put(_key, jsonEncode(model.toJson()));
    await _metadata.saveTimestamp(HiveBoxes.dashboard);
  }

  Future<void> invalidate() async {
    await _box.clear();
    await _metadata.clearTimestamp(HiveBoxes.dashboard);
  }

  bool get isEmpty => _box.isEmpty;
}
