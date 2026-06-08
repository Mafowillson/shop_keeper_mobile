import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart';

@lazySingleton
class UpdateShopUseCase {
  final IAuthRepository _repository;

  const UpdateShopUseCase(this._repository);

  TaskEither<Failure, User> call({
    required String name,
    required String description,
  }) =>
      _repository.updateShop(name: name, description: description);
}
