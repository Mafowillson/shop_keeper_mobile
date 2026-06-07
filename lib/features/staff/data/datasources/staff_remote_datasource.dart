import 'package:dio/dio.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/staff/data/models/staff_model.dart';

class StaffRemoteDataSource {
  final Dio _dio;

  StaffRemoteDataSource(DioClient dioClient) : _dio = dioClient.client;

  Future<List<StaffModel>> listStaff() async {
    try {
      final res = await _dio.get(
        '/staff',
        queryParameters: {'page': 1, 'page_size': 100},
      );
      final list = res.data['staff'] as List<dynamic>? ?? [];
      return list
          .map((e) => StaffModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<StaffModel> toggleActive(String staffId,
      {required bool isActive}) async {
    try {
      final res = await _dio.put(
        '/staff/$staffId',
        data: {'is_active': isActive},
      );
      return StaffModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  String _err(DioException e) => e.response?.data is Map
      ? (e.response!.data as Map)['error'] as String? ?? e.message ?? 'Error'
      : e.message ?? 'Error';

  Future<StaffModel> createStaff({
    required String name,
    required String email,
    required String phoneNumber,
    String? shopId,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
      };
      if (shopId != null && shopId.isNotEmpty) body['shop_id'] = shopId;

      final res = await _dio.post('/staff', data: body);
      return StaffModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }
}
