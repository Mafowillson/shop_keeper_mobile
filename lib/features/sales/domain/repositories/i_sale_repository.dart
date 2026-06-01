import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/sales/domain/entities/cart_item.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';

abstract class ISaleRepository {
  TaskEither<Failure, List<Sale>> getSales({required String shopId});
  TaskEither<Failure, Sale> getSaleById(String id);
  TaskEither<Failure, Sale> recordSale({
    required String shopId,
    required List<CartItem> cartItems,
    required double paidAmount,
    required bool isCredit,
    String? customerId,
  });
}
