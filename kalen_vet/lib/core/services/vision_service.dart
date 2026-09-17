import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';

class VisionService {
  final String baseUrl;

  VisionService({String? baseUrl}) : baseUrl = baseUrl ?? ApiConfig.baseUrl;

  Future<Map<String, dynamic>> analyzeImage({
    required Uint8List imageBytes,
    required String filename,
    String prompt = 'Describe this image.',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/vision/analyze'),
    );

    request.fields['prompt'] = prompt;

    request.files.add(
      http.MultipartFile.fromBytes('file', imageBytes, filename: filename),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Vision API error ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid Vision API response.');
    }

    return decoded;
  }
}
