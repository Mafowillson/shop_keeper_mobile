import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isOnline => _isOnline;

  ConnectivityService() {
    _init();
  }

  /// Testing-only constructor — does NOT start platform connectivity monitoring.
  /// Safe to use in unit / widget tests without plugin setup.
  @visibleForTesting
  ConnectivityService.stub({bool isOnline = false}) {
    _isOnline = isOnline;
  }

  Future<void> _init() async {
    final results = await Connectivity().checkConnectivity();
    _isOnline = _hasConnection(results);
    notifyListeners();

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final online = _hasConnection(results);
      if (online != _isOnline) {
        _isOnline = online;
        notifyListeners();
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
