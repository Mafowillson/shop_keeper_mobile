import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/domain/repositories/i_sale_repository.dart';

@lazySingleton
class GetSaleDetailUseCase {
  final ISaleRepository _repository;

  const GetSaleDetailUseCase(this._repository);

  TaskEither<Failure, Sale> call(String id) => _repository.getSaleById(id);
}
