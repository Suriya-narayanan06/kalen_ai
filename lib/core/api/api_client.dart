import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';

class ApiClient {
  Future<Map<String, dynamic>> getStatus() async {
    final response = await http
        .get(
          Uri.parse(ApiConfig.baseUrl),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)
          as Map<String, dynamic>;
    }

    throw Exception(
      'KALEN API error: ${response.statusCode}',
    );
  }
}