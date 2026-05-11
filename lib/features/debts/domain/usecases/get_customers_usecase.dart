import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/domain/repositories/i_debt_repository.dart';

@lazySingleton
class GetCustomersUseCase {
  final IDebtRepository _repository;

  const GetCustomersUseCase(this._repository);

  TaskEither<Failure, List<Customer>> call() => _repository.getCustomers();
}
