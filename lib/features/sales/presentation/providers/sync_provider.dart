import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/enums/sync_state.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/core/offline/connectivity_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/core/offline/sync_log_entry.dart';
import 'package:shopkeeper/features/debts/data/datasources/debt_local_datasource.dart';
import 'package:shopkeeper/features/debts/data/models/customer_model.dart';
import 'package:shopkeeper/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:shopkeeper/features/notifications/data/models/notification_model.dart';
import 'package:shopkeeper/features/products/data/datasources/product_local_datasource.dart';
import 'package:shopkeeper/features/products/data/models/product_model.dart';
import 'package:shopkeeper/features/sales/data/datasources/sale_local_datasource.dart';
import 'package:shopkeeper/features/sales/data/models/sale_model.dart';
import 'package:shopkeeper/main.dart' show localNotifications;

class SyncProvider extends ChangeNotifier {
  final ConnectivityService _connectivity;
  final DioClient _dioClient;
  final ProductLocalDataSource _productLocal;
  final SaleLocalDataSource _saleLocal;
  final DebtLocalDataSource _debtLocal;
  final NotificationLocalDataSource _notifLocal;
  final CacheMetadataService _metadata;

  SyncState _state = SyncState.synced;
  bool _isSyncing = false;
  String? _shopId;
  StreamSubscription<BoxEvent>? _syncLogSub;
  Timer? _backgroundRefreshTimer;

  SyncState get state => _state;
  bool get isOnline => _connectivity.isOnline;

  SyncProvider({
    required ConnectivityService connectivity,
    required DioClient dioClient,
    required ProductLocalDataSource productLocal,
    required SaleLocalDataSource saleLocal,
    required DebtLocalDataSource debtLocal,
    required NotificationLocalDataSource notifLocal,
    required CacheMetadataService metadata,
  })  : _connectivity = connectivity,
        _dioClient = dioClient,
        _productLocal = productLocal,
        _saleLocal = saleLocal,
        _debtLocal = debtLocal,
        _notifLocal = notifLocal,
        _metadata = metadata {
    _connectivity.addListener(_onConnectivityChanged);
    _watchSyncLog();
  }

  void initialize(String shopId) {
    _shopId = shopId;
    if (_hasPendingEntries()) {
      _state = SyncState.pending;
    } else if (_hasConflictEntries()) {
      _state = SyncState.conflict;
    }
    notifyListeners();
    if (_connectivity.isOnline) {
      _triggerSync();
      _startBackgroundRefreshTimer();
    }
  }

  void stop() {
    _shopId = null;
    _backgroundRefreshTimer?.cancel();
    _backgroundRefreshTimer = null;
  }

  // ── Phase 0: Proactive background refresh ─────────────────────────────────
  //
  // Even when there are no pending offline writes, any stale box is refreshed
  // automatically.  This keeps the cache warm for users on slow 3G.

  void _startBackgroundRefreshTimer() {
    _backgroundRefreshTimer?.cancel();
    // Check every 2 minutes; staleness thresholds per box determine what runs.
    _backgroundRefreshTimer =
        Timer.periodic(const Duration(minutes: 2), (_) => _backgroundRefresh());
  }

  Future<void> _backgroundRefresh() async {
    if (!_connectivity.isOnline || _shopId == null || _isSyncing) return;
    final shopId = _shopId!;

    final staleBoxes = [
      HiveBoxes.products,
      HiveBoxes.sales,
      HiveBoxes.customers,
      HiveBoxes.notifications,
      HiveBoxes.dashboard,
    ].where((box) => _metadata.isStale(box)).toList();

    if (staleBoxes.isEmpty) return;

    debugPrint('[SyncProvider] Phase 0: refreshing stale boxes $staleBoxes');
    await _pullUpdates(shopId, boxes: staleBoxes);
  }

  // ── Connectivity listener ─────────────────────────────────────────────────

  void _onConnectivityChanged() {
    notifyListeners();
    if (_connectivity.isOnline && _shopId != null) {
      _triggerSync();
      _startBackgroundRefreshTimer();
    } else {
      _backgroundRefreshTimer?.cancel();
    }
  }

  void _watchSyncLog() {
    final box = Hive.box(HiveBoxes.syncLog);
    _syncLogSub = box.watch().listen((_) {
      if (_hasPendingEntries() && _state == SyncState.synced) {
        _state = SyncState.pending;
        notifyListeners();
      }
    });
  }

  Future<void> _triggerSync() async {
    if (_isSyncing || _shopId == null) return;
    if (!_hasPendingEntries()) return;

    _isSyncing = true;
    _state = SyncState.pending;
    notifyListeners();

    try {
      final idMap = await _pushPendingEntries();
      await _applyIdMap(idMap);
      await _pullUpdates(_shopId!);
      await _checkConflicts();
      _state = _hasConflictEntries() ? SyncState.conflict : SyncState.synced;
    } catch (e) {
      debugPrint('[SyncProvider] sync error: $e');
      _state = SyncState.error;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // ── Phase 1: Push ─────────────────────────────────────────────────────────

  Future<Map<String, String>> _pushPendingEntries() async {
    final box = Hive.box(HiveBoxes.syncLog);
    final pending = _loadPending(box)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (pending.isEmpty) return {};

    final dio = _dioClient.client;
    final resp = await dio.post('/sync/push', data: {
      'records': pending.map((e) => e.toJson()).toList(),
    });

    final syncedIds =
        (resp.data['synced'] as List? ?? []).cast<String>().toSet();
    final conflictIds =
        (resp.data['conflicts'] as List? ?? []).cast<String>().toSet();
    final idMap = (resp.data['id_map'] as Map? ?? {}).cast<String, String>();

    for (final entry in pending) {
      if (syncedIds.contains(entry.id)) {
        await box.put(
            entry.id,
            jsonEncode(
                entry.copyWith(status: SyncEntryStatus.synced).toJson()));
      } else if (conflictIds.contains(entry.id)) {
        await box.put(
            entry.id,
            jsonEncode(
                entry.copyWith(status: SyncEntryStatus.conflict).toJson()));
      }
    }
    return idMap;
  }

  // ── Phase 1b: Apply id_map ────────────────────────────────────────────────

  Future<void> _applyIdMap(Map<String, String> idMap) async {
    for (final tempId in idMap.keys) {
      await _saleLocal.removeTempEntry(tempId);
      await _debtLocal.removeTempCustomer(tempId);
    }
  }

  // ── Phase 2: Pull — upgraded to refresh ALL entity types ─────────────────

  Future<void> _pullUpdates(String shopId, {List<String>? boxes}) async {
    final pull = boxes ??
        [
          HiveBoxes.products,
          HiveBoxes.sales,
          HiveBoxes.customers,
          HiveBoxes.notifications,
        ];

    final dio = _dioClient.client;

    if (pull.contains(HiveBoxes.products)) {
      try {
        final res = await dio.get('/products', queryParameters: {
          'shop_id': shopId,
          'page': 1,
          'page_size': 500,
        });
        final list = (res.data['products'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(ProductModel.fromJson)
            .toList();
        await _productLocal.cacheProducts(list);
      } catch (e) {
        debugPrint('[SyncProvider] product pull failed: $e');
      }
    }

    if (pull.contains(HiveBoxes.sales)) {
      try {
        final res = await dio.get('/sales', queryParameters: {
          'shop_id': shopId,
          'page': 1,
          'page_size': 100,
        });
        final list = (res.data['sales'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(SaleModel.fromJson)
            .toList();
        await _saleLocal.cacheSales(list);
      } catch (e) {
        debugPrint('[SyncProvider] sales pull failed: $e');
      }
    }

    if (pull.contains(HiveBoxes.customers)) {
      try {
        final res =
            await dio.get('/customers', queryParameters: {'shop_id': shopId});
        final list = (res.data['customers'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(CustomerModel.fromJson)
            .toList();
        await _debtLocal.cacheCustomers(list);
      } catch (e) {
        debugPrint('[SyncProvider] customer pull failed: $e');
      }
    }

    if (pull.contains(HiveBoxes.notifications)) {
      try {
        final res = await dio.get('/notifications');
        final list = (res.data['notifications'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList();
        await _notifLocal.saveNotifications(list);
      } catch (e) {
        debugPrint('[SyncProvider] notification pull failed: $e');
      }
    }
  }

  // ── Phase 3: Conflict notification ────────────────────────────────────────

  Future<void> _checkConflicts() async {
    final box = Hive.box(HiveBoxes.syncLog);
    final hasConflicts =
        _loadEntries(box).any((e) => e.status == SyncEntryStatus.conflict);
    if (!hasConflicts) return;

    const notifId = 9001;
    const androidDetails = AndroidNotificationDetails(
      'shopkeeper_alerts',
      'ShopKeeper Alerts',
      channelDescription: 'Sales, stock, debt and staff alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    await localNotifications.show(
      notifId,
      'Sync conflicts detected',
      'Some offline transactions need your review.',
      const NotificationDetails(android: androidDetails),
    );
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  bool _hasPendingEntries() {
    final box = Hive.box(HiveBoxes.syncLog);
    return _loadPending(box).isNotEmpty;
  }

  bool _hasConflictEntries() {
    final box = Hive.box(HiveBoxes.syncLog);
    return _loadEntries(box).any((e) => e.status == SyncEntryStatus.conflict);
  }

  List<SyncLogEntry> _loadPending(Box box) => _loadEntries(box)
      .where((e) => e.status == SyncEntryStatus.pending)
      .toList();

  List<SyncLogEntry> _loadEntries(Box box) => box.values
      .whereType<String>()
      .map((raw) {
        try {
          return SyncLogEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        } catch (_) {
          return null;
        }
      })
      .whereType<SyncLogEntry>()
      .toList();

  @override
  void dispose() {
    _connectivity.removeListener(_onConnectivityChanged);
    _syncLogSub?.cancel();
    _backgroundRefreshTimer?.cancel();
    super.dispose();
  }
}
