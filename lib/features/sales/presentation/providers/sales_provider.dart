import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/enums/date_filter.dart';
import 'package:shopkeeper/features/sales/domain/usecases/get_sale_detail_usecase.dart';
import 'package:shopkeeper/features/sales/domain/usecases/get_sales_usecase.dart';
import 'package:shopkeeper/features/sales/domain/usecases/record_sale_usecase.dart';

@injectable
class SalesProvider extends ChangeNotifier {
  final GetSalesUseCase _getSales;
  final GetSaleDetailUseCase _getSaleDetail;
  final RecordSaleUseCase _recordSale;

  SalesProvider(this._getSales, this._getSaleDetail, this._recordSale);

  bool _isLoading = false;
  String? _errorMessage;
  DateFilter _selectedFilter = DateFilter.today;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateFilter get selectedFilter => _selectedFilter;

  Future<void> loadSales(DateFilter filter) async {
    _selectedFilter = filter;
    _isLoading = true;
    notifyListeners();

    final result = await _getSales(filter: filter).run();

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
