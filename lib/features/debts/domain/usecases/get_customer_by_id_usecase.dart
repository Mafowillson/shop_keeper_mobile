import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/domain/repositories/i_debt_repository.dart';

@lazySingleton
class GetCustomerByIdUseCase {
  final IDebtRepository _repository;

  const GetCustomerByIdUseCase(this._repository);

  TaskEither<Failure, Customer> call(String id) => _repository.getCustomerById(id);
}
