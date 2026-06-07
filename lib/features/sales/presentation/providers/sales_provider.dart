import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/features/sales/domain/entities/cart_item.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/domain/usecases/get_sale_detail_usecase.dart';
import 'package:shopkeeper/features/sales/domain/usecases/get_sales_usecase.dart';
import 'package:shopkeeper/features/sales/domain/usecases/record_sale_usecase.dart';

@injectable
class SalesProvider extends ChangeNotifier {
  final GetSalesUseCase _getSales;
  final GetSaleDetailUseCase _getSaleDetail;
  final RecordSaleUseCase _recordSale;

  SalesProvider(this._getSales, this._getSaleDetail, this._recordSale);

  List<Sale> _sales = [];
  Sale? _currentSale;
  bool _isLoading = false;
  bool _isRecording = false;
  String? _errorMessage;

  List<Sale> get sales => _sales;
  Sale? get currentSale => _currentSale;
  bool get isLoading => _isLoading;
  bool get isRecording => _isRecording;
  String? get errorMessage => _errorMessage;

  double get totalRevenue => _sales.fold(0, (sum, s) => sum + s.totalAmount);

  // ── Load sales history ────────────────────────────────────────────────────

  Future<void> loadSales(String shopId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getSales(shopId: shopId).run();

    result.fold(
      (f) => _errorMessage = f.message,
      (list) {
        _sales = list..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // ── Load sale detail ──────────────────────────────────────────────────────

  Future<void> loadSaleDetail(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getSaleDetail(id).run();

    result.fold(
      (f) => _errorMessage = f.message,
      (sale) => _currentSale = sale,
    );

    _isLoading = false;
    notifyListeners();
  }

  // ── Record a new sale ─────────────────────────────────────────────────────

  Future<Sale?> recordSale({
    required String shopId,
    required List<CartItem> cartItems,
    required double paidAmount,
    required bool isCredit,
    String? customerId,
  }) async {
    _isRecording = true;
    _errorMessage = null;
    notifyListeners();

    Sale? created;
    final result = await _recordSale(
      shopId: shopId,
      cartItems: cartItems,
      paidAmount: paidAmount,
      isCredit: isCredit,
      customerId: customerId,
    ).run();

    result.fold(
      (f) => _errorMessage = f.message,
      (sale) {
        created = sale;
        _currentSale = sale;
        _sales = [sale, ..._sales];
      },
    );

    _isRecording = false;
    notifyListeners();
    return created;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
