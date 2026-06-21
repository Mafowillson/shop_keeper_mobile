import 'package:flutter/foundation.dart';
import 'package:shopkeeper/features/ai/price_recommendations/data/datasources/price_recommendation_datasource.dart';
import 'package:shopkeeper/features/ai/price_recommendations/domain/entities/price_recommendation.dart';

class PriceRecommendationProvider extends ChangeNotifier {
  final PriceRecommendationDataSource _dataSource;

  PriceRecommendationProvider(this._dataSource);

  List<PriceRecommendation> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  List<PriceRecommendation> get recommendations =>
      List.unmodifiable(_recommendations);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load(String shopId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final models = await _dataSource.fetchPending(shopId);
      _recommendations = models.map((m) => m.toEntity()).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> accept(String id) async {
    try {
      await _dataSource.accept(id);
      _recommendations = _recommendations.where((r) => r.id != id).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> dismiss(String id) async {
    try {
      await _dataSource.dismiss(id);
      _recommendations = _recommendations.where((r) => r.id != id).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
