import 'package:flutter/foundation.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/offline/connectivity_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:shopkeeper/features/notifications/data/models/notification_model.dart';
import 'package:shopkeeper/features/notifications/domain/entities/app_notification.dart';
import 'package:shopkeeper/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:shopkeeper/features/notifications/domain/usecases/mark_all_read_usecase.dart';
import 'package:shopkeeper/features/notifications/domain/usecases/mark_read_usecase.dart';

// Registered manually in injection.dart.
class NotificationProvider extends ChangeNotifier {
  final GetNotificationsUseCase _getNotifications;
  final MarkReadUseCase _markRead;
  final MarkAllReadUseCase _markAllRead;
  final NotificationLocalDataSource _local;
  final CacheMetadataService _metadata;
  final ConnectivityService _connectivity;

  NotificationProvider(
    this._getNotifications,
    this._markRead,
    this._markAllRead,
    this._local,
    this._metadata,
    this._connectivity,
  );

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  bool _isStaff = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _metadata.getTimestamp(HiveBoxes.notifications);

  // ── Stale-while-revalidate load ───────────────────────────────────────────

  Future<void> loadNotifications({bool isStaff = false}) async {
    _isStaff = isStaff;
    _errorMessage = null;

    final cached = _local.getNotifications();
    if (cached.isNotEmpty) {
      _notifications = cached.map((m) => m.toEntity()).toList();
      _isLoading = false;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    if (_connectivity.isOnline) {
      _isRefreshing = cached.isNotEmpty;
      if (_isRefreshing) notifyListeners();
      final result = await _getNotifications(isStaff: isStaff).run();
      result.fold(
        (f) {
          if (_notifications.isEmpty) _errorMessage = f.message;
        },
        (fresh) {
          _notifications = fresh;
          _local.saveNotifications(
              fresh.map(NotificationModel.fromEntity).toList());
        },
      );
      _isRefreshing = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    // Optimistic local update.
    _notifications = _notifications
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    notifyListeners();
    await _local.markRead(id);

    if (_connectivity.isOnline) {
      final result = await _markRead(id, isStaff: _isStaff).run();
      result.fold((f) => _errorMessage = f.message, (_) {});
    }
  }

  Future<void> markAllAsRead() async {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    await _local.markAllRead();

    if (_connectivity.isOnline) {
      final result = await _markAllRead(isStaff: _isStaff).run();
      result.fold((f) => _errorMessage = f.message, (_) {});
    }
  }
}
