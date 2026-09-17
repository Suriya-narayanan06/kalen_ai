import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/vision_service.dart';

class VisionScreen extends StatefulWidget {
  const VisionScreen({super.key});

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> {
  final ImagePicker _picker = ImagePicker();
  final VisionService _visionService = VisionService();

  Uint8List? _imageBytes;
  String? _filename;
  String? _result;
  bool _loading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _filename = image.name;
        _result = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _result = 'Unable to select image: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageBytes == null || _filename == null) return;

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final response = await _visionService.analyzeImage(
        imageBytes: _imageBytes!,
        filename: _filename!,
        prompt: 'Describe the important objects and scene in this image.',
      );

      if (!mounted) return;

      final analysis = response['analysis'];

      setState(() {
        _result = analysis is Map
            ? analysis['description']?.toString()
            : response.toString();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _result = 'Vision request failed: $e';
      });
    }

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('KALEN Vision'),
        backgroundColor: const Color(0xFF0D1117),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _imageBytes == null
                      ? const Center(
                          child: Icon(
                            Icons.visibility,
                            size: 80,
                            color: Color(0xFF22D3EE),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              if (_result != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _result!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _loading
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _loading
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: (_imageBytes == null || _loading)
                      ? null
                      : _analyzeImage,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _loading ? 'KALEN is analyzing...' : 'Analyze with KALEN',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
