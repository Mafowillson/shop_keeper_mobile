import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart';

@lazySingleton
class RegisterShopUseCase {
  final IAuthRepository _repository;

  const RegisterShopUseCase(this._repository);

  TaskEither<Failure, User> call({
    required String shopName,
    required String ownerId,
  }) =>
      _repository.registerShop(
        shopName: shopName,
        ownerId: ownerId,
      );
}
