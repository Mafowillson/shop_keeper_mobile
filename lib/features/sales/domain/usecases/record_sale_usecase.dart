import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale_item.dart';
import 'package:shopkeeper/features/sales/domain/repositories/i_sale_repository.dart';

@lazySingleton
class RecordSaleUseCase {
  final ISaleRepository _saleRepo;
  final IProductRepository _productRepo;

  const RecordSaleUseCase(this._saleRepo, this._productRepo);

  TaskEither<Failure, Unit> call(Sale sale, List<SaleItem> items) =>
      _saleRepo.recordSale(sale, items).flatMap((_) =>
          items.fold<TaskEither<Failure, Unit>>(
            TaskEither.right(unit),
            (acc, item) => acc.flatMap((_) =>
                _productRepo.decrementStock(item.productId, item.quantity)),
          ));
}
