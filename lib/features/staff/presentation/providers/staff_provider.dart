import 'package:flutter/foundation.dart';
import 'package:shopkeeper/features/staff/domain/entities/staff_entity.dart';
import 'package:shopkeeper/features/staff/domain/usecases/create_staff_usecase.dart';

class StaffProvider extends ChangeNotifier {
  final CreateStaffUseCase _createStaff;

  StaffProvider(this._createStaff);

  bool _isLoading = false;
  String? _errorMessage;
  StaffEntity? _lastCreatedStaff;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  StaffEntity? get lastCreatedStaff => _lastCreatedStaff;

  Future<bool> createStaff({
    required String name,
    required String email,
    required String phoneNumber,
    String? shopId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    bool success = false;
    try {
      final result = await _createStaff(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        shopId: shopId,
      ).run();
      result.fold(
        (f) => _errorMessage = f.message,
        (staff) {
          _lastCreatedStaff = staff;
          success = true;
        },
      );
    } catch (e) {
      debugPrint('[Staff] createStaff uncaught: $e');
      _errorMessage = 'Failed to create staff: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
