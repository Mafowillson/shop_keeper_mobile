import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/enums/message_role.dart';
import 'package:shopkeeper/features/ai_chat/domain/entities/chat_message.dart';
import 'package:shopkeeper/features/ai_chat/domain/usecases/clear_history_usecase.dart';
import 'package:shopkeeper/features/ai_chat/domain/usecases/load_history_usecase.dart';
import 'package:shopkeeper/features/ai_chat/domain/usecases/send_message_usecase.dart';
@injectable
class ChatProvider extends ChangeNotifier {
  final SendMessageUseCase _sendMessage;
  final LoadHistoryUseCase _loadHistory;
  final ClearHistoryUseCase _clearHistory;

  ChatProvider(this._sendMessage, this._loadHistory, this._clearHistory);

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _loadHistory().run();

    result.fold(
      (failure) => _errorMessage = failure.message,
      (history) {
        _messages
          ..clear()
          ..addAll(history);
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    final userMsg = ChatMessage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.user,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    _messages.add(userMsg);
    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _sendMessage(text.trim()).run();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _messages.removeLast();
      },
      (reply) {
        _messages.add(ChatMessage(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}_reply',
          role: MessageRole.assistant,
          text: reply,
          timestamp: DateTime.now(),
        ));
      },
    );

    _isSending = false;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    final result = await _clearHistory().run();

    result.fold(
      (failure) => _errorMessage = failure.message,
      (_) => _messages.clear(),
    );

    notifyListeners();
  }
}
