import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/enums/date_filter.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/domain/repositories/i_sale_repository.dart';

@lazySingleton
class GetSalesUseCase {
  final ISaleRepository _repository;

  const GetSalesUseCase(this._repository);

  TaskEither<Failure, List<Sale>> call({required DateFilter filter}) =>
      _repository.getSales(filter: filter);
}
