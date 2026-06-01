import 'package:shopkeeper/features/sales/data/models/sale_model.dart';

abstract class ISaleRemoteDataSource {
  Future<List<SaleModel>> getSales({required String shopId, int page = 1, int pageSize = 100});
  Future<SaleModel> getSaleById(String id);
  Future<SaleModel> createSale(Map<String, dynamic> body);
}
