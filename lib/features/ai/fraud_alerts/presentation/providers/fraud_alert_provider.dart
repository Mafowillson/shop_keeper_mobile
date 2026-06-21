import 'package:flutter/foundation.dart';
import 'package:shopkeeper/features/ai/fraud_alerts/data/datasources/fraud_alert_datasource.dart';
import 'package:shopkeeper/features/ai/fraud_alerts/domain/entities/fraud_alert.dart';

class FraudAlertProvider extends ChangeNotifier {
  final FraudAlertDataSource _dataSource;

  FraudAlertProvider(this._dataSource);

  List<FraudAlert> _alerts = [];
  bool _isLoading = false;
  String? _error;

  List<FraudAlert> get alerts => List.unmodifiable(_alerts);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get openCount => _alerts.where((a) => a.isOpen).length;

  Future<void> load(String shopId, {bool openOnly = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final models = openOnly
          ? await _dataSource.fetchOpen(shopId)
          : await _dataSource.fetchAll(shopId);
      _alerts = models.map((m) => m.toEntity()).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acknowledge(String id) async {
    // Optimistically mark as acknowledged in the list.
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts = List.of(_alerts);
      _alerts[index] = _alerts[index].copyWith(
        status: 'acknowledged',
        acknowledgedAt: DateTime.now(),
      );
      notifyListeners();
    }

    try {
      await _dataSource.acknowledge(id);
    } catch (e) {
      // Roll back optimistic update on failure.
      if (index != -1) {
        _alerts = List.of(_alerts);
        _alerts[index] = _alerts[index].copyWith(status: 'open');
        notifyListeners();
      }
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
