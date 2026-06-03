import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/domain/entities/debt_record.dart';

abstract class IDebtRepository {
  TaskEither<Failure, List<Customer>> getCustomers({required String shopId, bool? hasDebt});
  TaskEither<Failure, Customer> getCustomerById(String id);
  TaskEither<Failure, Customer> createCustomer({required String shopId, required String name, String? phone});
  TaskEither<Failure, List<DebtRecord>> getDebtHistory(String customerId);
  TaskEither<Failure, Unit> recordPayment(String customerId, double amount, String? note);
}
