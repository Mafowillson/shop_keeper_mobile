import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:shopkeeper/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';

@injectable
class DashboardProvider extends ChangeNotifier {
  final GetDashboardStatsUseCase _getStats;

  DashboardProvider(this._getStats);

  DashboardStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getStats().run();

    result.fold(
      (failure) => _errorMessage = failure.message,
      (s) => _stats = s,
    );

    _isLoading = false;
    notifyListeners();
  }
}
