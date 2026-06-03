import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/domain/entities/debt_record.dart';
import 'package:shopkeeper/features/debts/domain/usecases/create_customer_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_customer_by_id_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_customers_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_debt_history_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/record_payment_usecase.dart';

@injectable
class DebtProvider extends ChangeNotifier {
  final GetCustomersUseCase _getCustomers;
  final GetCustomerByIdUseCase _getCustomerById;
  final CreateCustomerUseCase _createCustomer;
  final GetDebtHistoryUseCase _getDebtHistory;
  final RecordPaymentUseCase _recordPayment;

  DebtProvider(
    this._getCustomers,
    this._getCustomerById,
    this._createCustomer,
    this._getDebtHistory,
    this._recordPayment,
  );

  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  List<DebtRecord> _debtHistory = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  List<DebtRecord> get debtHistory => _debtHistory;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  double get totalOutstandingDebt =>
      _customers.fold(0, (sum, c) => sum + c.totalDebt);

  List<Customer> get customersWithDebt =>
      _customers.where((c) => c.totalDebt > 0).toList();

  Future<void> loadCustomers(String shopId, {bool? hasDebt}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getCustomers(shopId: shopId, hasDebt: hasDebt).run();
    result.fold(
      (f) => _errorMessage = f.message,
      (list) => _customers = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCustomerDetail(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _debtHistory = [];
    notifyListeners();

    final customerResult = await _getCustomerById(id).run();
    customerResult.fold(
      (f) { _errorMessage = f.message; _isLoading = false; notifyListeners(); return; },
      (c) => _selectedCustomer = c,
    );

    if (_selectedCustomer == null) return;

    final historyResult = await _getDebtHistory(id).run();
    historyResult.fold(
      (f) => _errorMessage = f.message,
      (list) => _debtHistory = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Returns the newly created customer, or null on failure (check [errorMessage]).
  Future<Customer?> createCustomer({
    required String shopId,
    required String name,
    String? phone,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    Customer? created;
    final result = await _createCustomer(shopId: shopId, name: name, phone: phone).run();
    result.fold(
      (f) => _errorMessage = f.message,
      (c) {
        created = c;
        _customers = [c, ..._customers];
      },
    );

    _isSaving = false;
    notifyListeners();
    return created;
  }

  /// Records a payment. Returns true on success.
  Future<bool> recordPayment(String customerId, double amount, String? note) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    bool success = false;
    final result = await _recordPayment(customerId, amount, note).run();
    result.fold(
      (f) => _errorMessage = f.message,
      (_) {
        success = true;
        // Update local customer debt balance.
        _customers = _customers.map((c) {
          if (c.id == customerId) {
            return c.copyWith(totalDebt: (c.totalDebt - amount).clamp(0, double.infinity));
          }
          return c;
        }).toList();
        if (_selectedCustomer?.id == customerId) {
          _selectedCustomer = _selectedCustomer!.copyWith(
            totalDebt: (_selectedCustomer!.totalDebt - amount).clamp(0, double.infinity),
          );
        }
      },
    );

    _isSaving = false;
    notifyListeners();
    return success;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
