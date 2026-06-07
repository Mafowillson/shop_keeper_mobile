import 'package:hive/hive.dart';
import 'package:shopkeeper/core/cache/cache_status.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';

/// Stores and queries per-box last-updated timestamps.
///
/// Timestamps are persisted in [HiveBoxes.cacheMetadata] so they survive
/// app restarts.  All reads are synchronous (Hive in-memory lookup).
class CacheMetadataService {
  Box get _box => Hive.box(HiveBoxes.cacheMetadata);

  /// Saves [DateTime.now()] for [boxName].
  Future<void> saveTimestamp(String boxName) async {
    await _box.put(boxName, DateTime.now().toIso8601String());
  }

  /// Removes the timestamp for [boxName], marking it as never synced.
  Future<void> clearTimestamp(String boxName) async {
    await _box.delete(boxName);
  }

  /// Returns the last-updated [DateTime] for [boxName], or null if never set.
  DateTime? getTimestamp(String boxName) {
    final raw = _box.get(boxName) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Returns how long ago the box was last updated, or null if never updated.
  Duration? getAge(String boxName) {
    final ts = getTimestamp(boxName);
    if (ts == null) return null;
    return DateTime.now().difference(ts);
  }

  /// Returns true when the box has exceeded its staleness threshold.
  bool isStale(String boxName) {
    final age = getAge(boxName);
    if (age == null) return true;
    return age > StaleThresholds.forBox(boxName);
  }

  /// Returns the [CacheStatus] for [boxName] given whether the box has data.
  CacheStatus statusFor(String boxName, {required bool hasData}) {
    if (!hasData) return CacheStatus.empty;
    return isStale(boxName) ? CacheStatus.stale : CacheStatus.fresh;
  }

  /// Clears all timestamps.  Called on logout.
  Future<void> clearAll() async {
    await _box.clear();
  }
}
