import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/ai_chat/data/datasources/i_chat_remote_datasource.dart';
import 'package:shopkeeper/features/ai_chat/data/models/chat_message_model.dart';

@LazySingleton(as: IChatRemoteDataSource)
class ChatRemoteDataSourceImpl implements IChatRemoteDataSource {
  final Dio _dio;

  ChatRemoteDataSourceImpl(DioClient dioClient) : _dio = dioClient.client;

  @override
  Future<String> sendMessage(String message) async {
    try {
      final res = await _dio.post('/chat/message', data: {'message': message});
      return res.data['reply'] as String;
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  @override
  Future<List<ChatMessageModel>> loadHistory() async {
    try {
      final res = await _dio.get('/chat/history');
      final list = res.data['messages'] as List<dynamic>? ?? [];
      return list
          .cast<Map<String, dynamic>>()
          .map(ChatMessageModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await _dio.delete('/chat/history');
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  String _errorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map)
      return data['error'] as String? ?? e.message ?? 'Request failed';
    return e.message ?? 'Request failed';
  }
}
