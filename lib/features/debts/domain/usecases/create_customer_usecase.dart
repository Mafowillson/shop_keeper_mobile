import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/domain/repositories/i_debt_repository.dart';

@lazySingleton
class CreateCustomerUseCase {
  final IDebtRepository _repository;

  const CreateCustomerUseCase(this._repository);

  TaskEither<Failure, Customer> call({
    required String shopId,
    required String name,
    String? phone,
  }) =>
      _repository.createCustomer(shopId: shopId, name: name, phone: phone);
}
