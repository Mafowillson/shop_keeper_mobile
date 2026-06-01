import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/sales/data/datasources/i_sale_remote_datasource.dart';
import 'package:shopkeeper/features/sales/data/models/sale_model.dart';

@LazySingleton(as: ISaleRemoteDataSource)
class SaleRemoteDataSourceImpl implements ISaleRemoteDataSource {
  final Dio _dio;

  SaleRemoteDataSourceImpl(DioClient dioClient) : _dio = dioClient.client;

  @override
  Future<List<SaleModel>> getSales({
    required String shopId,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final res = await _dio.get('/sales', queryParameters: {
        'shop_id': shopId,
        'page': page,
        'page_size': pageSize,
      });
      final list = res.data['sales'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>().map(SaleModel.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<SaleModel> getSaleById(String id) async {
    try {
      final res = await _dio.get('/sales/$id');
      return SaleModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<SaleModel> createSale(Map<String, dynamic> body) async {
    try {
      final res = await _dio.post('/sales', data: body);
      return SaleModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  String _msg(DioException e) {
    final d = e.response?.data;
    if (d is Map) return d['error'] as String? ?? e.message ?? 'Request failed';
    return e.message ?? 'Request failed';
  }
}
