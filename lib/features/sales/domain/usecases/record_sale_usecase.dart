import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/sales/domain/entities/cart_item.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/domain/repositories/i_sale_repository.dart';

@lazySingleton
class RecordSaleUseCase {
  final ISaleRepository _saleRepo;

  const RecordSaleUseCase(this._saleRepo);

  TaskEither<Failure, Sale> call({
    required String shopId,
    required List<CartItem> cartItems,
    required double paidAmount,
    required bool isCredit,
    String? customerId,
  }) =>
      _saleRepo.recordSale(
        shopId: shopId,
        cartItems: cartItems,
        paidAmount: paidAmount,
        isCredit: isCredit,
        customerId: customerId,
      );
}
