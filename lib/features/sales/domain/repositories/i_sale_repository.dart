import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/enums/date_filter.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale_item.dart';

abstract class ISaleRepository {
  TaskEither<Failure, List<Sale>> getSales({required DateFilter filter});
  TaskEither<Failure, Sale> getSaleById(String id);
  TaskEither<Failure, Unit> recordSale(Sale sale, List<SaleItem> items);
}
