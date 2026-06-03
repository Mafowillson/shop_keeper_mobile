import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/sales/data/datasources/i_sale_remote_datasource.dart';
import 'package:shopkeeper/features/sales/domain/entities/cart_item.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/domain/repositories/i_sale_repository.dart';

@LazySingleton(as: ISaleRepository)
class SaleRepositoryImpl implements ISaleRepository {
  final ISaleRemoteDataSource _remote;

  const SaleRepositoryImpl(this._remote);

  @override
  TaskEither<Failure, List<Sale>> getSales({required String shopId}) =>
      TaskEither.tryCatch(
        () async {
          final models = await _remote.getSales(shopId: shopId);
          return models.map((m) => m.toEntity()).toList();
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, Sale> getSaleById(String id) =>
      TaskEither.tryCatch(
        () async {
          final model = await _remote.getSaleById(id);
          return model.toEntity();
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, Sale> recordSale({
    required String shopId,
    required List<CartItem> cartItems,
    required double paidAmount,
    required bool isCredit,
    String? customerId,
  }) =>
      TaskEither.tryCatch(
        () async {
          final items = cartItems.map((c) => {
            'product_id': c.product.id,
            'unit': c.unit.name,
            'quantity': c.quantity,
          }).toList();

          final body = <String, dynamic>{
            'shop_id': shopId,
            'items': items,
            'paid_amount': paidAmount,
            'is_credit': isCredit,
          };
          if (customerId != null && customerId.isNotEmpty) {
            body['customer_id'] = customerId;
          }

          final model = await _remote.createSale(body);
          return model.toEntity();
        },
        (e, _) => ServerFailure('$e'),
      );
}
