import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_customers_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_debt_history_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/record_payment_usecase.dart';

@injectable
class DebtProvider extends ChangeNotifier {
  final GetCustomersUseCase _getCustomers;
  final GetDebtHistoryUseCase _getDebtHistory;
  final RecordPaymentUseCase _recordPayment;

  DebtProvider(
    this._getCustomers,
    this._getDebtHistory,
    this._recordPayment,
  );

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getCustomers().run();

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
