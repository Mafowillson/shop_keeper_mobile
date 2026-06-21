import 'package:flutter/foundation.dart';
import 'package:shopkeeper/features/ai/weekly_insights/data/datasources/weekly_insight_datasource.dart';
import 'package:shopkeeper/features/ai/weekly_insights/domain/entities/weekly_insight.dart';

class WeeklyInsightProvider extends ChangeNotifier {
  final WeeklyInsightDataSource _dataSource;

  WeeklyInsightProvider(this._dataSource);

  List<WeeklyInsight> _insights = [];
  bool _isLoading = false;
  String? _error;

  List<WeeklyInsight> get insights => List.unmodifiable(_insights);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load(String shopId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final models = await _dataSource.fetch(shopId);
      _insights = models.map((m) => m.toEntity()).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
