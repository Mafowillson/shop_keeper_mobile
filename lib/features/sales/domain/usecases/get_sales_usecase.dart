import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/domain/repositories/i_sale_repository.dart';

@lazySingleton
class GetSalesUseCase {
  final ISaleRepository _repository;

  const GetSalesUseCase(this._repository);

  TaskEither<Failure, List<Sale>> call({required String shopId}) =>
      _repository.getSales(shopId: shopId);
}
