import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/debts/data/datasources/i_debt_remote_datasource.dart';
import 'package:shopkeeper/features/debts/data/models/customer_model.dart';
import 'package:shopkeeper/features/debts/data/models/debt_record_model.dart';

@LazySingleton(as: IDebtRemoteDataSource)
class DebtRemoteDataSourceImpl implements IDebtRemoteDataSource {
  final Dio _dio;

  DebtRemoteDataSourceImpl(DioClient dioClient) : _dio = dioClient.client;

  @override
  Future<List<CustomerModel>> getCustomers(
      {required String shopId, bool? hasDebt}) async {
    try {
      final params = <String, dynamic>{'shop_id': shopId};
      if (hasDebt != null) params['has_debt'] = hasDebt;
      final res = await _dio.get('/customers', queryParameters: params);
      final list = res.data['customers'] as List<dynamic>? ?? [];
      return list
          .cast<Map<String, dynamic>>()
          .map(CustomerModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    try {
      final res = await _dio.get('/customers/$id');
      return CustomerModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<CustomerModel> createCustomer({
    required String shopId,
    required String name,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{'shop_id': shopId, 'name': name};
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      final res = await _dio.post('/customers', data: body);
      return CustomerModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<List<DebtRecordModel>> getDebtHistory(String customerId) async {
    try {
      final res = await _dio.get('/customers/$customerId/debts');
      final list = res.data['debt_records'] as List<dynamic>? ?? [];
      return list
          .cast<Map<String, dynamic>>()
          .map(DebtRecordModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<DebtRecordModel> recordPayment(
      String customerId, double amount, String? note) async {
    try {
      final body = <String, dynamic>{'amount': amount.toStringAsFixed(0)};
      if (note != null && note.isNotEmpty) body['note'] = note;
      final res = await _dio.post('/customers/$customerId/payment', data: body);
      return DebtRecordModel.fromJson(res.data as Map<String, dynamic>);
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
