import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/features/ai_chat/domain/usecases/load_history_usecase.dart';
import 'package:shopkeeper/features/ai_chat/domain/usecases/send_message_usecase.dart';

@injectable
class ChatProvider extends ChangeNotifier {
  final SendMessageUseCase _sendMessage;
  final LoadHistoryUseCase _loadHistory;

  ChatProvider(this._sendMessage, this._loadHistory);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    final result = await _loadHistory().run();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (_) {
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
