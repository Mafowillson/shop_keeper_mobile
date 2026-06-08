import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart';

@lazySingleton
class SwitchActiveShopUseCase {
  final IAuthRepository _repository;

  const SwitchActiveShopUseCase(this._repository);

  TaskEither<Failure, User> call({
    required String shopId,
    required String shopName,
    required String shopDescription,
  }) =>
      _repository.setActiveShop(
        shopId: shopId,
        shopName: shopName,
        shopDescription: shopDescription,
      );
}
