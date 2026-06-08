import 'package:flutter/foundation.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/offline/connectivity_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/features/debts/data/datasources/debt_local_datasource.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/domain/entities/debt_record.dart';
import 'package:shopkeeper/features/debts/domain/usecases/create_customer_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_customer_by_id_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_customers_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_debt_history_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/record_payment_usecase.dart';

// Registered manually in injection.dart.
class DebtProvider extends ChangeNotifier {
  final GetCustomersUseCase _getCustomers;
  final GetCustomerByIdUseCase _getCustomerById;
  final CreateCustomerUseCase _createCustomer;
  final GetDebtHistoryUseCase _getDebtHistory;
  final RecordPaymentUseCase _recordPayment;
  final DebtLocalDataSource _local;
  final CacheMetadataService _metadata;
  final ConnectivityService _connectivity;

  DebtProvider(
    this._getCustomers,
    this._getCustomerById,
    this._createCustomer,
    this._getDebtHistory,
    this._recordPayment,
    this._local,
    this._metadata,
    this._connectivity,
  );

  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  List<DebtRecord> _debtHistory = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  List<DebtRecord> get debtHistory => _debtHistory;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _metadata.getTimestamp(HiveBoxes.customers);

  double get totalOutstandingDebt =>
      _customers.fold(0, (sum, c) => sum + c.totalDebt);

  List<Customer> get customersWithDebt =>
      _customers.where((c) => c.totalDebt > 0).toList();

  // ── Stale-while-revalidate load ───────────────────────────────────────────

  Future<void> loadCustomers(String shopId, {bool? hasDebt}) async {
    _errorMessage = null;

    final cached = _local.getCustomers(shopId: shopId, hasDebt: hasDebt);
    if (cached.isNotEmpty) {
      _customers = cached.map((m) => m.toEntity()).toList();
      _isLoading = false;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    if (_connectivity.isOnline) {
      _isRefreshing = cached.isNotEmpty;
      if (_isRefreshing) notifyListeners();
      final result =
          await _getCustomers(shopId: shopId, hasDebt: hasDebt).run();
      result.fold(
        (f) {
          if (_customers.isEmpty) _errorMessage = f.message;
        },
        (fresh) => _customers = fresh,
      );
      _isRefreshing = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCustomerDetail(String id) async {
    _errorMessage = null;
    _debtHistory = [];

    final cachedCustomer = _local.getCustomerById(id);
    if (cachedCustomer != null) {
      _selectedCustomer = cachedCustomer.toEntity();
      _isLoading = false;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    final cachedHistory = _local.getDebtHistory(id);
    if (cachedHistory.isNotEmpty) {
      _debtHistory = cachedHistory.map((m) => m.toEntity()).toList();
      notifyListeners();
    }

    if (_connectivity.isOnline) {
      final customerResult = await _getCustomerById(id).run();
      customerResult.fold(
        (f) {
          if (_selectedCustomer == null) _errorMessage = f.message;
        },
        (c) => _selectedCustomer = c,
      );
      if (_selectedCustomer != null) {
        final historyResult = await _getDebtHistory(id).run();
        historyResult.fold(
          (f) {
            if (_debtHistory.isEmpty) _errorMessage = f.message;
          },
          (list) => _debtHistory = list,
        );
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Customer?> createCustomer({
    required String shopId,
    required String name,
    String? phone,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    Customer? created;
    final result =
        await _createCustomer(shopId: shopId, name: name, phone: phone).run();
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

  Future<bool> recordPayment(
      String customerId, double amount, String? note) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    bool success = false;
    final result = await _recordPayment(customerId, amount, note).run();
    result.fold(
      (f) => _errorMessage = f.message,
      (_) {
        success = true;
        _customers = _customers.map((c) {
          if (c.id == customerId) {
            return c.copyWith(
                totalDebt: (c.totalDebt - amount).clamp(0, double.infinity));
          }
          return c;
        }).toList();
        if (_selectedCustomer?.id == customerId) {
          _selectedCustomer = _selectedCustomer!.copyWith(
            totalDebt: (_selectedCustomer!.totalDebt - amount)
                .clamp(0, double.infinity),
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
