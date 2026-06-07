import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/features/notifications/data/models/notification_model.dart';

class NotificationLocalDataSource {
  final CacheMetadataService _metadata;

  NotificationLocalDataSource(this._metadata);

  Box get _box => Hive.box(HiveBoxes.notifications);

  List<NotificationModel> getNotifications() {
    return _box.values
        .whereType<String>()
        .map((raw) {
          try {
            return NotificationModel.fromJson(
                jsonDecode(raw) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<NotificationModel>()
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveNotifications(List<NotificationModel> models) async {
    final entries = {for (final n in models) n.id: jsonEncode(n.toJson())};
    await _box.putAll(entries);
    await _metadata.saveTimestamp(HiveBoxes.notifications);
  }

  Future<void> markRead(String id) async {
    final raw = _box.get(id) as String?;
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      json['is_read'] = true;
      await _box.put(id, jsonEncode(json));
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    final updates = <String, String>{};
    for (final key in _box.keys) {
      final raw = _box.get(key) as String?;
      if (raw == null) continue;
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        json['is_read'] = true;
        updates[key as String] = jsonEncode(json);
      } catch (_) {}
    }
    if (updates.isNotEmpty) await _box.putAll(updates);
  }

  Future<void> invalidate() async {
    await _box.clear();
    await _metadata.clearTimestamp(HiveBoxes.notifications);
  }

  bool get isEmpty => _box.isEmpty;
}
