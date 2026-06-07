import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/debts/domain/repositories/i_debt_repository.dart';

@lazySingleton
class RecordPaymentUseCase {
  final IDebtRepository _repository;

  const RecordPaymentUseCase(this._repository);

  TaskEither<Failure, Unit> call(
          String customerId, double amount, String? note) =>
      _repository.recordPayment(customerId, amount, note);
}
