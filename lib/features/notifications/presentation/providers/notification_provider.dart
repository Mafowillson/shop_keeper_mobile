import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/features/notifications/domain/entities/app_notification.dart';
import 'package:shopkeeper/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:shopkeeper/features/notifications/domain/usecases/mark_all_read_usecase.dart';
import 'package:shopkeeper/features/notifications/domain/usecases/mark_read_usecase.dart';

@injectable
class NotificationProvider extends ChangeNotifier {
  final GetNotificationsUseCase _getNotifications;
  final MarkReadUseCase _markRead;
  final MarkAllReadUseCase _markAllRead;

  NotificationProvider(
    this._getNotifications,
    this._markRead,
    this._markAllRead,
  );

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getNotifications().run();

    result.fold(
      (failure) => _errorMessage = failure.message,
      (list) => _notifications = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final result = await _markRead(id).run();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (_) {
        _notifications = _notifications
            .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
            .toList();
      },
    );
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    final result = await _markAllRead().run();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (_) {
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
      },
    );
    notifyListeners();
  }
}
