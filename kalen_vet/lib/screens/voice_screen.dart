import 'package:flutter/material.dart';

import '../core/services/kalen_voice_service.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final KalenVoiceService _voice = KalenVoiceService();

  bool _recording = false;
  bool _processing = false;

  String _transcript = '';
  String _status = 'KALEN VOICE READY';

  Future<void> _toggleRecording() async {
    if (_processing) return;

    try {
      if (!_recording) {
        final allowed = await _voice.requestPermission();

        if (!allowed) {
          setState(() {
            _status = 'MICROPHONE PERMISSION DENIED';
          });
          return;
        }

        await _voice.startRecording();

        setState(() {
          _recording = true;
          _status = 'LISTENING...';
        });
      } else {
        setState(() {
          _recording = false;
          _processing = true;
          _status = 'PROCESSING VOICE...';
        });

        final text = await _voice.stopRecordingAndTranscribe();

        if (!mounted) return;

        setState(() {
          _transcript = text ?? '';
          _status = text == null || text.isEmpty
              ? 'NO SPEECH DETECTED'
              : 'TRANSCRIPTION COMPLETE';
        });

        if (text != null && text.trim().isNotEmpty) {
          await _voice.speak('I heard: $text');
        }

        if (!mounted) return;

        setState(() {
          _processing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _recording = false;
        _processing = false;
        _status = 'VOICE ERROR';
        _transcript = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050B14),
        title: const Text(
          'KALEN VOICE',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _toggleRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: _recording ? 150 : 130,
                  height: _recording ? 150 : 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.cyanAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(
                          alpha: _recording ? 0.45 : 0.18,
                        ),
                        blurRadius: 35,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    _recording ? Icons.stop : Icons.mic,
                    size: 55,
                    color: Colors.cyanAccent,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              if (_transcript.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.cyanAccent.withValues(alpha: 0.35),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _transcript,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                _recording
                    ? 'Tap to stop'
                    : _processing
                    ? 'KALEN is processing...'
                    : 'Tap microphone to speak',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
