import 'package:dio/dio.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/staff/data/models/staff_model.dart';

class StaffRemoteDataSource {
  final Dio _dio;

  StaffRemoteDataSource(DioClient dioClient) : _dio = dioClient.client;

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
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['error'] as String? ?? e.message
          : e.message;
      throw Exception(msg ?? 'Failed to create staff member');
    }
  }
}
