import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class KalenVoiceService {
  KalenVoiceService({String? baseUrl})
    : baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'KALEN_API_URL',
            defaultValue: 'https://kalen-ai.onrender.com',
          );

  final String baseUrl;

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _recording = false;

  bool get isRecording => _recording;

  Future<bool> requestPermission() async {
    return _recorder.hasPermission();
  }

  Future<void> startRecording() async {
    if (_recording) return;

    final allowed = await _recorder.hasPermission();

    if (!allowed) {
      throw Exception('Microphone permission denied');
    }

    final directory = await getTemporaryDirectory();

    final path = '${directory.path}/kalen_voice.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );

    _recording = true;
  }

  Future<String?> stopRecordingAndTranscribe() async {
    if (!_recording) return null;

    final path = await _recorder.stop();

    _recording = false;

    if (path == null) {
      throw Exception('Recording path unavailable');
    }

    final file = File(path);

    if (!await file.exists()) {
      throw Exception('Recorded audio file not found');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/voice/transcribe'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        file.path,
        filename: 'kalen_voice.m4a',
      ),
    );

    final response = await request.send();

    final body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Voice transcription failed '
        '(${response.statusCode}): $body',
      );
    }

    final data = jsonDecode(body) as Map<String, dynamic>;

    return data['text']?.toString();
  }

  Future<void> speak(String text) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) return;

    final response = await http.post(
      Uri.parse('$baseUrl/voice/tts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': cleanText}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'KALEN TTS failed '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final directory = await getTemporaryDirectory();

    final path = '${directory.path}/kalen_response.mp3';

    final file = File(path);

    await file.writeAsBytes(response.bodyBytes, flush: true);

    await _player.stop();

    await _player.play(DeviceFileSource(file.path));
  }

  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
