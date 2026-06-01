import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/features/staff/domain/entities/staff_dashboard_stats.dart';
import 'package:shopkeeper/features/staff/domain/usecases/get_staff_dashboard_usecase.dart';

@injectable
class StaffDashboardProvider extends ChangeNotifier {
  final GetStaffDashboardUseCase _getStats;

  StaffDashboardProvider(this._getStats);

  StaffDashboardStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  StaffDashboardStats? get stats => _stats;
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
