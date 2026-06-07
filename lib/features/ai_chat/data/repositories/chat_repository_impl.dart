import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/ai_chat/data/datasources/i_chat_remote_datasource.dart';
import 'package:shopkeeper/features/ai_chat/domain/entities/chat_message.dart';
import 'package:shopkeeper/features/ai_chat/domain/repositories/i_chat_repository.dart';

@LazySingleton(as: IChatRepository)
class ChatRepositoryImpl implements IChatRepository {
  final IChatRemoteDataSource _remote;

  const ChatRepositoryImpl(this._remote);

  @override
  TaskEither<Failure, String> sendMessage(String msg) => TaskEither.tryCatch(
        () => _remote.sendMessage(msg),
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, List<ChatMessage>> loadHistory() => TaskEither.tryCatch(
        () async {
          final models = await _remote.loadHistory();
          return models.map((m) => m.toEntity()).toList();
        },
        (e, _) => ServerFailure('$e'),
      );

  @override
  TaskEither<Failure, Unit> clearHistory() => TaskEither.tryCatch(
        () async {
          await _remote.clearHistory();
          return unit;
        },
        (e, _) => ServerFailure('$e'),
      );
}
