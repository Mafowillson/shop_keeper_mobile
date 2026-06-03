import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/debts/data/datasources/i_debt_remote_datasource.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/domain/entities/debt_record.dart';
import 'package:shopkeeper/features/debts/domain/repositories/i_debt_repository.dart';

@LazySingleton(as: IDebtRepository)
class DebtRepositoryImpl implements IDebtRepository {
  final IDebtRemoteDataSource _remote;

  const DebtRepositoryImpl(this._remote);

  @override
  TaskEither<Failure, List<Customer>> getCustomers({required String shopId, bool? hasDebt}) =>
      TaskEither.tryCatch(
        () async {
          final models = await _remote.getCustomers(shopId: shopId, hasDebt: hasDebt);
          return models.map((m) => m.toEntity()).toList();
        },
        (e, _) => ServerFailure(e.toString()),
      );

  @override
  TaskEither<Failure, Customer> getCustomerById(String id) =>
      TaskEither.tryCatch(
        () async => (await _remote.getCustomerById(id)).toEntity(),
        (e, _) => ServerFailure(e.toString()),
      );

  @override
  TaskEither<Failure, Customer> createCustomer({required String shopId, required String name, String? phone}) =>
      TaskEither.tryCatch(
        () async => (await _remote.createCustomer(shopId: shopId, name: name, phone: phone)).toEntity(),
        (e, _) => ServerFailure(e.toString()),
      );

  @override
  TaskEither<Failure, List<DebtRecord>> getDebtHistory(String customerId) =>
      TaskEither.tryCatch(
        () async {
          final models = await _remote.getDebtHistory(customerId);
          return models.map((m) => m.toEntity()).toList();
        },
        (e, _) => ServerFailure(e.toString()),
      );

  @override
  TaskEither<Failure, Unit> recordPayment(String customerId, double amount, String? note) =>
      TaskEither.tryCatch(
        () async {
          await _remote.recordPayment(customerId, amount, note);
          return unit;
        },
        (e, _) => ServerFailure(e.toString()),
      );
}
