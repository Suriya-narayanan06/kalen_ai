import 'package:flutter/foundation.dart';

class AiService {
  const AiService();

  Future<String> sendMessage({
    required String message,
  }) async {
    debugPrint('AI request: $message');

    // Backend connection will be implemented here.
    //
    // Flutter UI -> AiService -> Your Backend -> AI Provider
    //
    // Do not place provider API keys in this Flutter application.

    await Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    return 'AI service is connected to the application layer. '
        'The backend provider will be connected next.';
  }
}