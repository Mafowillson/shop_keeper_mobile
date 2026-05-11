import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';

@injectable
class DashboardProvider extends ChangeNotifier {
  final GetDashboardStatsUseCase _getStats;

  DashboardProvider(this._getStats);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getStats().run();

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
