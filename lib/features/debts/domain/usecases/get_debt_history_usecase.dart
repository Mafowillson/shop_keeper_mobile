import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/debts/domain/entities/debt_record.dart';
import 'package:shopkeeper/features/debts/domain/repositories/i_debt_repository.dart';

@lazySingleton
class GetDebtHistoryUseCase {
  final IDebtRepository _repository;

  const GetDebtHistoryUseCase(this._repository);

  TaskEither<Failure, List<DebtRecord>> call(String customerId) =>
      _repository.getDebtHistory(customerId);
}
