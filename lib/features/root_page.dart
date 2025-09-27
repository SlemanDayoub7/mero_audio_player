import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';

class RingtoneTrimPage extends StatefulWidget {
  final String path;
  const RingtoneTrimPage({Key? key, required this.path}) : super(key: key);

  @override
  State<RingtoneTrimPage> createState() => _RingtoneTrimPageState();
}

class _RingtoneTrimPageState extends State<RingtoneTrimPage> {
  File? _selectedFile;
  double _startTime = 0.0;
  double _endTime = 30.0;
  double _maxDuration = 60.0;
  bool _isLoading = false;
  bool _isTrimming = false;

  // Native method channel (same as before)
  static const platform = MethodChannel(
    'com.example.mero_audio_player/audio_trimmer',
  );

  Future<String?> _trimAudio(String inputPath, int startMs, int endMs) async {
    try {
      final String? outputPath = await platform.invokeMethod('trimAudio', {
        'inputPath': inputPath,
        'startMs': startMs,
        'endMs': endMs,
      });
      return outputPath;
    } on PlatformException catch (e) {
      return null;
    }
  }

  Future<void> _estimateAudioDuration() async {
    if (_selectedFile == null) return;

    try {
      // Simple estimation - you can enhance this with actual duration detection
      // For now, we'll assume max 3 minutes for ringtones
      setState(() {
        _maxDuration = 180.0; // 3 minutes max
        _endTime = _endTime.clamp(0, _maxDuration);
      });
    } catch (e) {}
  }

  Future<void> _setAsRingtone() async {
    if (_selectedFile == null) {
      _showSnackBar('Please select an audio file first');
      return;
    }

    if (_startTime >= _endTime) {
      _showSnackBar('Start time must be before end time');
      return;
    }

    setState(() {
      _isLoading = true;
      _isTrimming = true;
    });

    try {
      // Trim the audio using native code
      final String? trimmedPath = await _trimAudio(
        _selectedFile!.path,
        (_startTime * 1000).round(), // Convert to milliseconds
        (_endTime * 1000).round(),
      );

      if (trimmedPath == null) {
        _showSnackBar('Failed to trim audio');
        return;
      }

      setState(() {
        _isTrimming = false;
      });

      // Set as ringtone
      final success = await RingtoneSet.setRingtoneFromFile(File(trimmedPath));

      // Clean up temporary file
      try {
        final tempFile = File(trimmedPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e) {}

      if (success) {
        _showSnackBar('✅ Ringtone set successfully!');
      } else {
        _showSnackBar('Failed to set ringtone');
      }
    } on PlatformException {
      _showSnackBar('Error setting ringtone');
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isTrimming = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  String _formatTime(double seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toStringAsFixed(0).padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _selectedFile = File(widget.path);
      _startTime = 0.0;
      _endTime = 30.0; // Reset to default 30 seconds
    });

    // Try to get actual duration
    _estimateAudioDuration();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Custom Ringtone'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // File selection card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.audio_file, size: 48, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFile?.path.split('/').last ?? 'No file selected',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _selectedFile != null ? Colors.green : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Trimming controls
            if (_selectedFile != null) ...[
              const Text(
                'Trim Your Ringtone',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Duration info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Start:'),
                          Text(_formatTime(_startTime)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('End:'),
                          Text(_formatTime(_endTime)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Duration:'),
                          Text(
                            _formatTime(_endTime - _startTime),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Start time slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start Time'),
                  Slider(
                    value: _startTime,
                    min: 0,
                    max: _maxDuration,
                    divisions: _maxDuration.round(),
                    label: _formatTime(_startTime),
                    onChanged: (value) {
                      if (value < _endTime) {
                        setState(() {
                          _startTime = value;
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // End time slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('End Time'),
                  Slider(
                    value: _endTime,
                    min: 0,
                    max: _maxDuration,
                    divisions: _maxDuration.round(),
                    label: _formatTime(_endTime),
                    onChanged: (value) {
                      if (value > _startTime) {
                        setState(() {
                          _endTime = value;
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Set ringtone button
              ElevatedButton(
                onPressed: _isLoading ? null : _setAsRingtone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isTrimming
                                ? const Text('Trimming...')
                                : const Text('Setting Ringtone...'),
                            const SizedBox(width: 8),
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                        : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.ring_volume),
                            SizedBox(width: 8),
                            Text(
                              'Set as Ringtone',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
              ),

              const SizedBox(height: 16),

              // Quick preset buttons
              const Text(
                'Quick Presets:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _startTime = 0;
                          _endTime = 15;
                        });
                      },
                      child: const Text('15s'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _startTime = 0;
                          _endTime = 30;
                        });
                      },
                      child: const Text('30s'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _startTime = 0;
                          _endTime = 45;
                        });
                      },
                      child: const Text('45s'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Empty state
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Select an audio file to create your custom ringtone',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
