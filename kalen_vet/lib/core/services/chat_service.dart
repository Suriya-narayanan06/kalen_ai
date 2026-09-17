import '../api/api_client.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<String> sendMessage(String message, {String? sessionId}) async {
    final response = await _apiClient.post('/chat/send', {
      'message': message,
      'session_id': sessionId,
    });

    if (response['error'] != null) {
      throw Exception(response['error'].toString());
    }

    return response['reply']?.toString() ?? 'No response from KALEN.';
  }
}
