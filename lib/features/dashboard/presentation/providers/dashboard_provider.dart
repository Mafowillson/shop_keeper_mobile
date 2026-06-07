import 'package:flutter/foundation.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/offline/connectivity_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:shopkeeper/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:shopkeeper/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:shopkeeper/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';

// Registered manually in injection.dart.
class DashboardProvider extends ChangeNotifier {
  final GetDashboardStatsUseCase _getStats;
  final DashboardLocalDataSource _local;
  final CacheMetadataService _metadata;
  final ConnectivityService _connectivity;

  DashboardProvider(
    this._getStats,
    this._local,
    this._metadata,
    this._connectivity,
  );

  DashboardStats? _stats;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _metadata.getTimestamp(HiveBoxes.dashboard);

  // ── Stale-while-revalidate load ───────────────────────────────────────────

  Future<void> loadStats() async {
    _errorMessage = null;

    final cached = _local.getStats();
    if (cached != null) {
      _stats = cached.toEntity();
      _isLoading = false;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    if (_connectivity.isOnline) {
      _isRefreshing = cached != null;
      if (_isRefreshing) notifyListeners();
      final result = await _getStats().run();
      result.fold(
        (f) {
          if (_stats == null) _errorMessage = f.message;
        },
        (fresh) {
          _stats = fresh;
          _local.saveStats(DashboardStatsModel(
            todaySales: fresh.todaySales,
            transactionCount: fresh.transactionCount,
            lowStockCount: fresh.lowStockCount,
            totalDebts: fresh.totalDebts,
            weeklyRevenue: fresh.weeklyRevenue,
            activityFeed: fresh.activityFeed
                .map((a) => ActivityFeedModel(
                      id: a.id,
                      title: a.title,
                      subtitle: a.subtitle,
                      timestamp: a.timestamp,
                      type: a.type,
                    ))
                .toList(),
          ));
        },
      );
      _isRefreshing = false;
    }

    _isLoading = false;
    notifyListeners();
  }
}
