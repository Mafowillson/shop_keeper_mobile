import 'package:shopkeeper/features/debts/data/models/customer_model.dart';
import 'package:shopkeeper/features/debts/data/models/debt_record_model.dart';

abstract class IDebtRemoteDataSource {
  Future<List<CustomerModel>> getCustomers({required String shopId, bool? hasDebt});
  Future<CustomerModel> getCustomerById(String id);
  Future<CustomerModel> createCustomer({required String shopId, required String name, String? phone});
  Future<List<DebtRecordModel>> getDebtHistory(String customerId);
  Future<DebtRecordModel> recordPayment(String customerId, double amount, String? note);
}
