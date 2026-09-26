import 'dart:convert';
import 'package:http/http.dart' as http;

class KalenApi {
  static const String baseUrl = 'https://kalen-ai.onrender.com';

  static Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply']?.toString() ?? 'No response from KALEN.';
    }

    throw Exception('KALEN API error: ${response.statusCode}');
  }
}
