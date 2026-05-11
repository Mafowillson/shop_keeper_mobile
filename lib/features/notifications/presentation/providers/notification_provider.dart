import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
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

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getNotifications().run();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (_) {
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
