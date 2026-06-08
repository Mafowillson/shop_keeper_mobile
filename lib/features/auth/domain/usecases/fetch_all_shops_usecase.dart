import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/domain/entities/shop_summary.dart';
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart';

@lazySingleton
class FetchAllShopsUseCase {
  final IAuthRepository _repository;

  const FetchAllShopsUseCase(this._repository);

  TaskEither<Failure, List<ShopSummary>> call() => _repository.fetchAllShops();
}
