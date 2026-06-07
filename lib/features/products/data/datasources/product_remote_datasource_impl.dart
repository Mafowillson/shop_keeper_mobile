import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/products/data/datasources/i_product_remote_datasource.dart';
import 'package:shopkeeper/features/products/data/models/product_model.dart';

@LazySingleton(as: IProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements IProductRemoteDataSource {
  final Dio _dio;

  ProductRemoteDataSourceImpl(DioClient dioClient) : _dio = dioClient.client;

  @override
  Future<List<ProductModel>> getProducts({
    required String shopId,
    String? search,
    String? category,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final params = <String, dynamic>{
        'shop_id': shopId,
        'page': page,
        'page_size': pageSize,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (category != null && category.isNotEmpty)
        params['category'] = category;

      final res = await _dio.get('/products', queryParameters: params);
      final list = res.data['products'] as List<dynamic>? ?? [];
      return list
          .cast<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final res = await _dio.get('/products/$id');
      return ProductModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel model) async {
    try {
      final res = await _dio.post('/products', data: model.toCreateRequest());
      return ProductModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  @override
  Future<ProductModel> updateProduct(String id, ProductModel model) async {
    try {
      final res =
          await _dio.put('/products/$id', data: model.toUpdateRequest());
      return ProductModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  @override
  Future<void> deactivateProduct(String id) async {
    try {
      await _dio.delete('/products/$id');
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  String _errorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map)
      return data['error'] as String? ?? e.message ?? 'Request failed';
    return e.message ?? 'Request failed';
  }
}
