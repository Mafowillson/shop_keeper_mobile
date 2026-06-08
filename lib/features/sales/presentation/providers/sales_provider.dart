import 'package:flutter/foundation.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/offline/connectivity_service.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/features/sales/data/datasources/sale_local_datasource.dart';
import 'package:shopkeeper/features/sales/domain/entities/cart_item.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/domain/usecases/get_sale_detail_usecase.dart';
import 'package:shopkeeper/features/sales/domain/usecases/get_sales_usecase.dart';
import 'package:shopkeeper/features/sales/domain/usecases/record_sale_usecase.dart';

// Registered manually in injection.dart.
class SalesProvider extends ChangeNotifier {
  final GetSalesUseCase _getSales;
  final GetSaleDetailUseCase _getSaleDetail;
  final RecordSaleUseCase _recordSale;
  final SaleLocalDataSource _local;
  final CacheMetadataService _metadata;
  final ConnectivityService _connectivity;

  SalesProvider(
    this._getSales,
    this._getSaleDetail,
    this._recordSale,
    this._local,
    this._metadata,
    this._connectivity,
  );

  List<Sale> _sales = [];
  Sale? _currentSale;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isRecording = false;
  String? _errorMessage;

  List<Sale> get sales => _sales;
  Sale? get currentSale => _currentSale;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isRecording => _isRecording;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _metadata.getTimestamp(HiveBoxes.sales);

  double get totalRevenue => _sales.fold(0, (sum, s) => sum + s.totalAmount);

  // ── Stale-while-revalidate load ───────────────────────────────────────────

  Future<void> loadSales(String shopId) async {
    _errorMessage = null;

    final cached = _local.getSales(shopId: shopId);
    if (cached.isNotEmpty) {
      _sales = cached.map((m) => m.toEntity()).toList();
      _isLoading = false;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    if (_connectivity.isOnline) {
      _isRefreshing = cached.isNotEmpty;
      if (_isRefreshing) notifyListeners();
      final result = await _getSales(shopId: shopId).run();
      result.fold(
        (f) {
          if (_sales.isEmpty) _errorMessage = f.message;
        },
        (fresh) =>
            _sales = fresh..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
      _isRefreshing = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSaleDetail(String id) async {
    _errorMessage = null;

    // Serve cache immediately — no spinner if we already have the data.
    final cachedModel = _local.getSaleById(id);
    if (cachedModel != null) {
      _currentSale = cachedModel.toEntity();
      _isLoading = false;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    if (_connectivity.isOnline) {
      final result = await _getSaleDetail(id).run();
      result.fold(
        (f) {
          if (_currentSale == null) _errorMessage = f.message;
        },
        (sale) => _currentSale = sale,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

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
        // Timestamp is written by the repository's local datasource on success.
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
