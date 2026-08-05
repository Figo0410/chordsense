import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'services/api_service.dart';

class GuitarString {
  final int number;
  final String noteName;
  final String label;
  final double frequency;
  bool isTuned;

  GuitarString({
    required this.number,
    required this.noteName,
    required this.label,
    required this.frequency,
    this.isTuned = false,
  });
}

class TunerScreen extends StatefulWidget {
  final String? userId;
  final VoidCallback? onTuningComplete;

  const TunerScreen({super.key, this.userId, this.onTuningComplete});

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen> {
  final List<GuitarString> _strings = [
    GuitarString(number: 1, noteName: "E", label: "High E", frequency: 329.63),
    GuitarString(number: 2, noteName: "B", label: "B", frequency: 246.94),
    GuitarString(number: 3, noteName: "G", label: "G", frequency: 196.00),
    GuitarString(number: 4, noteName: "D", label: "D", frequency: 146.83),
    GuitarString(number: 5, noteName: "A", label: "A", frequency: 110.00),
    GuitarString(number: 6, noteName: "E", label: "Low E", frequency: 82.41),
  ];

  int _selectedStringIndex = 0;
  bool _isListening = false;
  bool _isSaving = false;

  double _currentDeviation = 0.0;
  double _detectedFrequency = 0.0;

  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  late PitchDetector _pitchDetector;

  int get _tunedCount => _strings.where((s) => s.isTuned).length;

  @override
  void initState() {
    super.initState();
    _pitchDetector = PitchDetector();
    // Disabled auto-start so listening only begins when manually triggered
  }

  @override
  void dispose() {
    _stopTuner();
    super.dispose();
  }

  Future<void> _startTuner() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Microphone permission is required to tune."),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
      return;
    }

    try {
      if (_isListening) return;

      await _audioCapture.init();

      await _audioCapture.start(
        _audioCallback,
        _onError,
        sampleRate: 44100,
        bufferSize: 2048,
      );

      if (mounted) {
        setState(() {
          _isListening = true;
        });
      }
    } catch (e) {
      debugPrint("Error starting tuner: $e");
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
    }
  }

  void _audioCallback(dynamic obj) async {
    if (!_isListening || !mounted) return;

    List<double> audioBuffer = [];
    if (obj is Float64List) {
      audioBuffer = obj.toList();
    } else if (obj is List) {
      audioBuffer = obj.map((e) => (e as num).toDouble()).toList();
    }

    if (audioBuffer.isEmpty) return;

    try {
      // Ensure buffer length is a valid power of 2 expected by pitch_detector_dart
      int targetLength = 2048;
      List<double> formattedBuffer;
      if (audioBuffer.length > targetLength) {
        formattedBuffer = audioBuffer.sublist(0, targetLength);
      } else if (audioBuffer.length < targetLength) {
        formattedBuffer = List<double>.from(audioBuffer)
          ..addAll(List<double>.filled(targetLength - audioBuffer.length, 0.0));
      } else {
        formattedBuffer = audioBuffer;
      }

      final Float32List float32buffer = Float32List.fromList(formattedBuffer);
      final result = await _pitchDetector.getPitchFromFloatBuffer(
        float32buffer,
      );

      if (result.pitched && result.pitch > 30.0 && result.pitch < 1000.0) {
        final targetFreq = _strings[_selectedStringIndex].frequency;
        double cents = 1200 * (log(result.pitch / targetFreq) / log(2));

        if (mounted) {
          setState(() {
            _detectedFrequency = result.pitch;
            _currentDeviation = cents.clamp(-50.0, 50.0);

            // AUTO-MARKING LOGIC
            if (_currentDeviation.abs() <= 2.0 &&
                !_strings[_selectedStringIndex].isTuned) {
              _strings[_selectedStringIndex].isTuned = true;

              if (_tunedCount == 6) {
                _completeTuningProcess();
              } else {
                int nextUntuned = _strings.indexWhere(
                  (s) => !s.isTuned,
                  _selectedStringIndex,
                );
                if (nextUntuned == -1) {
                  nextUntuned = _strings.indexWhere((s) => !s.isTuned);
                }
                if (nextUntuned != -1) {
                  _selectedStringIndex = nextUntuned;
                  _currentDeviation = 0.0;
                }
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Pitch detection error: $e");
    }
  }

  void _onError(Object err) {
    debugPrint("Audio Capture Error: $err");
  }

  Future<void> _stopTuner() async {
    try {
      if (_isListening) {
        await _audioCapture.stop();
      }
    } catch (e) {
      debugPrint("Error stopping audio capture: $e");
    }
    if (mounted) {
      setState(() {
        _isListening = false;
        _detectedFrequency = 0.0;
        _currentDeviation = 0.0;
      });
    }
  }

  Future<void> _completeTuningProcess() async {
    if (widget.userId == null) {
      if (widget.onTuningComplete != null) widget.onTuningComplete!();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ApiService.updateTunerStatus(widget.userId!, true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Guitar tuned successfully! Practice is unlocked."),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
      if (widget.onTuningComplete != null) {
        widget.onTuningComplete!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Notice: Tuned locally ($e)"),
            backgroundColor: const Color(0xFFF97316),
          ),
        );
      }
      if (widget.onTuningComplete != null) {
        widget.onTuningComplete!();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeString = _strings[_selectedStringIndex];

    String statusText = "TUNING...";
    Color statusColor = Colors.white;
    if (_isListening) {
      if (_currentDeviation.abs() <= 2.0) {
        statusText = "✓ IN TUNE";
        statusColor = const Color(0xFF10B981);
      } else if (_currentDeviation < -2.0) {
        statusText = "TOO FLAT";
        statusColor = const Color(0xFFEF4444);
      } else {
        statusText = "TOO SHARP";
        statusColor = const Color(0xFFF97316);
      }
    } else {
      statusText = "PAUSED";
      statusColor = const Color(0xFF64748B);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Guitar Tuner",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Tune your guitar with real-time feedback",
              style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF071B2F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF0E3A5F)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.info, color: Color(0xFF0ea5e9), size: 16),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "How to Use",
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Tap a string below, then play that string on your guitar. The tuner will detect the pitch and automatically mark it as tuned.",
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isListening && _currentDeviation.abs() <= 2.0
                      ? const Color(0xFF10B981)
                      : const Color(0xFF1E293B),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${activeString.label} (${activeString.noteName}) • Detected: ${_detectedFrequency > 0 ? '${_detectedFrequency.toStringAsFixed(1)} Hz' : (_isListening ? 'Listening...' : 'Paused')}",
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double normalizedValue = ((_currentDeviation + 50) / 100)
                          .clamp(0.0, 1.0);
                      double needlePosition =
                          constraints.maxWidth * normalizedValue;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 24,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFF1E293B),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            left: Radius.circular(12),
                                          ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  color: Colors.green.withValues(alpha: 0.1),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            right: Radius.circular(12),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 3,
                            height: 30,
                            color: const Color(0xFF64748B),
                          ),
                          Positioned(
                            left: needlePosition - 6,
                            child: Container(
                              width: 12,
                              height: 28,
                              decoration: BoxDecoration(
                                color:
                                    _isListening &&
                                        _currentDeviation.abs() <= 2.0
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF97316),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_currentDeviation.abs() <= 2.0
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFF97316))
                                            .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "FLAT",
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "PERFECT",
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "SHARP",
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Column(
                    children: [
                      const Text(
                        "Deviation",
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${_currentDeviation >= 0 ? '+' : ''}${_currentDeviation.toStringAsFixed(1)} cents",
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select a String",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _strings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final string = _strings[index];
                final isSelected = index == _selectedStringIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStringIndex = index;
                      _currentDeviation = 0.0;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0284C7)
                            : const Color(0xFF1E293B),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(
                                        0xFF0284C7,
                                      ).withValues(alpha: 0.15)
                                    : const Color(0xFF1E293B),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF0284C7)
                                      : const Color(0xFF475569),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "${string.number}",
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${string.noteName} String",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${string.label} • ${string.frequency.toStringAsFixed(2)} Hz",
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        isSelected
                            ? Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0EA5E9),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Active",
                                    style: TextStyle(
                                      color: Color(0xFF0EA5E9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Icon(
                                string.isTuned
                                    ? LucideIcons.circle_check
                                    : LucideIcons.mic,
                                color: string.isTuned
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF475569),
                                size: 16,
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (_isListening) {
                    _stopTuner();
                  } else {
                    _startTuner();
                  }
                },
                child: Text(
                  _isListening ? "Stop Listening" : "Start Listening",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF011A13),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF064E3B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.circle_check,
                        color: Color(0xFF10B981),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tuning Progress",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$_tunedCount of 6 strings tuned",
                            style: const TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: List.generate(6, (index) {
                      bool isSegmentTuned = _strings[index].isTuned;
                      return Expanded(
                        child: Container(
                          height: 6,
                          margin: EdgeInsets.only(right: index < 5 ? 6.0 : 0.0),
                          decoration: BoxDecoration(
                            color: isSegmentTuned
                                ? const Color(0xFF10B981)
                                : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF059669)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isSaving
                          ? null
                          : () {
                              setState(() {
                                _strings[_selectedStringIndex].isTuned =
                                    !_strings[_selectedStringIndex].isTuned;
                              });

                              if (_tunedCount == 6) {
                                _completeTuningProcess();
                              }
                            },
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF10B981),
                              ),
                            )
                          : const Icon(
                              LucideIcons.check,
                              color: Color(0xFF10B981),
                              size: 16,
                            ),
                      label: Text(
                        _isSaving
                            ? "Saving..."
                            : (_strings[_selectedStringIndex].isTuned
                                  ? "Unmark String"
                                  : "Mark as Tuned"),
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
