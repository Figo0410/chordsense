import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import '../services/api_service.dart';

class GuidedPlayScreen extends StatefulWidget {
  final Map<String, dynamic>? lessonData;

  const GuidedPlayScreen({super.key, this.lessonData});

  @override
  State<GuidedPlayScreen> createState() => _GuidedPlayScreenState();
}

class _GuidedPlayScreenState extends State<GuidedPlayScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  late PitchDetector _pitchDetector;

  bool _isListening = false;
  double _detectedPitch = 0.0;
  String _detectedNote = "--";
  bool _isCorrectFeedback = false;

  int _currentChordIndex = 0;
  bool _isPlayingSound = false;
  bool _hasDetectedChord = false;
  String _feedbackMessage = "Strum your guitar to play";

  int _correctAttempts = 0;
  int _incorrectAttempts = 0;
  Timer? _sessionTimer;
  Timer? _feedbackResetTimer;
  int _elapsedSeconds = 0;

  List<String> _targetChords = ['D', 'F#m', 'Bm', 'G'];

  final Map<String, ChordDiagramData> _chordDiagrams = {
    'C': ChordDiagramData(
      stringStates: ['X', 'O', '', '', 'O', 'O'],
      dots: [
        FretDot(stringIndex: 1, fret: 3, finger: '3'),
        FretDot(stringIndex: 2, fret: 2, finger: '2'),
        FretDot(stringIndex: 4, fret: 1, finger: '1'),
      ],
    ),
    'G': ChordDiagramData(
      stringStates: ['', '', 'O', 'O', 'O', ''],
      dots: [
        FretDot(stringIndex: 0, fret: 3, finger: '2'),
        FretDot(stringIndex: 1, fret: 2, finger: '1'),
        FretDot(stringIndex: 5, fret: 3, finger: '3'),
      ],
    ),
    'Am': ChordDiagramData(
      stringStates: ['X', 'O', '', '', '', 'O'],
      dots: [
        FretDot(stringIndex: 2, fret: 2, finger: '2'),
        FretDot(stringIndex: 3, fret: 2, finger: '3'),
        FretDot(stringIndex: 4, fret: 1, finger: '1'),
      ],
    ),
    'F': ChordDiagramData(
      stringStates: ['X', 'X', '', '', '', ''],
      dots: [
        FretDot(stringIndex: 2, fret: 3, finger: '3'),
        FretDot(stringIndex: 3, fret: 2, finger: '2'),
        FretDot(stringIndex: 4, fret: 1, finger: '1'),
        FretDot(stringIndex: 5, fret: 1, finger: '1'),
      ],
    ),
    'Bm': ChordDiagramData(
      stringStates: ['X', '', '', '', '', ''],
      dots: [
        FretDot(stringIndex: 1, fret: 2, finger: '1'),
        FretDot(stringIndex: 2, fret: 4, finger: '3'),
        FretDot(stringIndex: 3, fret: 4, finger: '4'),
        FretDot(stringIndex: 4, fret: 3, finger: '2'),
      ],
    ),
    'F#': ChordDiagramData(
      stringStates: ['', '', '', '', '', ''],
      dots: [
        FretDot(stringIndex: 0, fret: 2, finger: '1'),
        FretDot(stringIndex: 1, fret: 4, finger: '3'),
        FretDot(stringIndex: 2, fret: 4, finger: '4'),
        FretDot(stringIndex: 3, fret: 3, finger: '2'),
      ],
    ),
    'F#m': ChordDiagramData(
      stringStates: ['', '', '', '', '', ''],
      dots: [
        FretDot(stringIndex: 0, fret: 2, finger: '1'),
        FretDot(stringIndex: 1, fret: 4, finger: '3'),
        FretDot(stringIndex: 2, fret: 4, finger: '4'),
        FretDot(stringIndex: 3, fret: 2, finger: '1'),
        FretDot(stringIndex: 4, fret: 2, finger: '1'),
        FretDot(stringIndex: 5, fret: 2, finger: '1'),
      ],
    ),
    'A': ChordDiagramData(
      stringStates: ['X', 'O', '', '', '', 'O'],
      dots: [
        FretDot(stringIndex: 2, fret: 2, finger: '1'),
        FretDot(stringIndex: 3, fret: 2, finger: '2'),
        FretDot(stringIndex: 4, fret: 2, finger: '3'),
      ],
    ),
    'E': ChordDiagramData(
      stringStates: ['O', '', '', '', 'O', 'O'],
      dots: [
        FretDot(stringIndex: 1, fret: 2, finger: '2'),
        FretDot(stringIndex: 2, fret: 2, finger: '3'),
        FretDot(stringIndex: 3, fret: 1, finger: '1'),
      ],
    ),
    'D': ChordDiagramData(
      stringStates: ['X', 'X', 'O', '', '', ''],
      dots: [
        FretDot(stringIndex: 3, fret: 2, finger: '1'),
        FretDot(stringIndex: 4, fret: 3, finger: '3'),
        FretDot(stringIndex: 5, fret: 2, finger: '2'),
      ],
    ),
  };

  final Map<String, List<double>> _chordFrequencies = {
    'C': [130.81, 164.81, 196.00, 261.63, 329.63],
    'C Major': [130.81, 164.81, 196.00, 261.63, 329.63],
    'G': [98.00, 123.47, 146.83, 196.00, 246.94, 392.00],
    'G Major': [98.00, 123.47, 146.83, 196.00, 246.94, 392.00],
    'Am': [110.00, 164.81, 220.00, 277.18, 329.63],
    'A Major': [110.00, 164.81, 220.00, 277.18, 329.63],
    'A': [110.00, 164.81, 220.00, 277.18, 329.63],
    'D Major': [146.83, 220.00, 293.66, 369.99],
    'D': [146.83, 220.00, 293.66, 369.99],
    'E Major': [82.41, 123.47, 164.81, 207.65, 246.94, 329.63],
    'E': [82.41, 123.47, 164.81, 207.65, 246.94, 329.63],
    'Bm': [123.47, 185.00, 246.94, 369.99, 493.88],
    'F#': [92.50, 138.59, 185.00, 277.18, 369.99],
    'F#m': [92.50, 138.59, 185.00, 277.18, 369.99],
    'F': [174.61, 220.00, 261.63, 349.23, 698.46],
  };

  @override
  void initState() {
    super.initState();
    _pitchDetector = PitchDetector();
    _extractLessonChords();
    _initAudioEngine();
    _startTimer();
  }

  void _extractLessonChords() {
    if (widget.lessonData != null) {
      if (widget.lessonData!['progression'] != null) {
        final List<dynamic> prog = widget.lessonData!['progression'];
        if (prog.isNotEmpty) {
          _targetChords = prog.map((c) => c.toString()).toList();
          return;
        }
      }
      if (widget.lessonData!['chords'] != null) {
        final List<dynamic> chords = widget.lessonData!['chords'];
        if (chords.isNotEmpty) {
          _targetChords = chords.map((c) => c.toString()).toList();
        }
      }
    }
  }

  Future<void> _initAudioEngine() async {
    await _audioCapture.init();
    _startMicListening();
  }

  Future<void> _startMicListening() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        setState(() {
          _feedbackMessage = "Microphone permission required.";
        });
      }
      return;
    }

    try {
      await _audioCapture.start(
        _onAudioStream,
        _onAudioError,
        sampleRate: 44100,
        bufferSize: 2048,
      );
      if (mounted) {
        setState(() {
          _isListening = true;
        });
      }
    } catch (e) {
      debugPrint("Error starting audio capture: $e");
    }
  }

  void _onAudioError(Object error) {
    debugPrint("Audio capture error: $error");
  }

  void _onAudioStream(dynamic obj) async {
    if (!_isListening || _hasDetectedChord || !mounted) return;

    List<double> audioBuffer = [];
    if (obj is Float64List) {
      audioBuffer = obj.toList();
    } else if (obj is List) {
      audioBuffer = obj.map((e) => (e as num).toDouble()).toList();
    }

    if (audioBuffer.isEmpty) return;

    try {
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

      if (result.pitched && result.pitch > 60.0 && result.pitch < 1000.0) {
        final double pitch = result.pitch;
        final String noteName = _frequencyToNoteName(pitch);

        if (mounted) {
          setState(() {
            _detectedPitch = pitch;
            _detectedNote = noteName;
          });
        }

        _verifyChordMatch(pitch);
      }
    } catch (e) {
      debugPrint("Pitch detection error: $e");
    }
  }

  void _verifyChordMatch(double pitch) {
    final String currentChord = _targetChords[_currentChordIndex];
    List<double>? validFreqs = _chordFrequencies[currentChord];

    if (validFreqs == null) {
      validFreqs = _chordFrequencies['$currentChord Major'];
    }

    bool isMatch = false;
    if (validFreqs != null) {
      for (double targetFreq in validFreqs) {
        if ((pitch - targetFreq).abs() <= 15.0) {
          isMatch = true;
          break;
        }
      }
    }

    _feedbackResetTimer?.cancel();

    if (isMatch) {
      _handleChordSuccess();
    } else {
      if (mounted && !_hasDetectedChord) {
        setState(() {
          _isCorrectFeedback = false;
          _feedbackMessage =
              "Detected $_detectedNote — Try adjusting your fingers!";
        });
        _incorrectAttempts++;
      }
    }
  }

  void _handleChordSuccess() {
    setState(() {
      _hasDetectedChord = true;
      _isCorrectFeedback = true;
      _correctAttempts++;
      _feedbackMessage = "Perfect! Chord $_detectedNote Matched!";
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentChordIndex < _targetChords.length - 1) {
        setState(() {
          _currentChordIndex++;
          _hasDetectedChord = false;
          _isCorrectFeedback = false;
          _detectedNote = "--";
          _feedbackMessage = "Strum your guitar to play";
        });
      } else {
        _finishSession();
      }
    });
  }

  String _frequencyToNoteName(double frequency) {
    final List<String> notes = [
      "C",
      "C#",
      "D",
      "D#",
      "E",
      "F",
      "F#",
      "G",
      "G#",
      "A",
      "A#",
      "B",
    ];

    if (frequency <= 0) return "--";
    int noteIndex = (12 * (log(frequency / 440.0) / log(2)) + 69).round() % 12;
    return notes[(noteIndex + 12) % 12];
  }

  void _startTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  Future<void> _playChordAudio(String chordName) async {
    try {
      setState(() => _isPlayingSound = true);
      String audioFile = 'audio/${chordName.replaceAll(' ', '')}.mp3';
      await _audioPlayer.play(AssetSource(audioFile));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    } finally {
      if (mounted) setState(() => _isPlayingSound = false);
    }
  }

  Future<void> _finishSession() async {
    _sessionTimer?.cancel();
    await _stopMicListening();

    int total = _correctAttempts + _incorrectAttempts;
    int accuracy = total > 0 ? ((_correctAttempts / total) * 100).round() : 100;
    int points = _correctAttempts * 20;

    await ApiService.savePracticeSession(
      userId: "user_123",
      levelId: widget.lessonData?['level'] ?? 1,
      chordPracticed: _targetChords.join(', '),
      totalAttempts: total > 0 ? total : _targetChords.length,
      correctAttempts: _correctAttempts > 0
          ? _correctAttempts
          : _targetChords.length,
      incorrectAttempts: _incorrectAttempts,
      accuracy: accuracy,
      pointsEarned: points > 0 ? points : 100,
      duration: _elapsedSeconds,
    );

    if (mounted) {
      _showCompletionDialog();
    }
  }

  Future<void> _stopMicListening() async {
    try {
      await _audioCapture.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
    } catch (e) {
      debugPrint("Error stopping audio capture: $e");
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _stopMicListening();
    } else {
      _startMicListening();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D1527),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Session Complete!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Great job! You practiced ${_targetChords.length} chords in ${_elapsedSeconds}s.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              "Continue",
              style: TextStyle(color: Color(0xFF00E5FF)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackResetTimer?.cancel();
    _stopMicListening();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String songTitle = widget.lessonData?['title'] ?? 'Hotel California';
    final String artistName = widget.lessonData?['artist'] ?? 'Eagles';
    final String currentChord = _targetChords[_currentChordIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrow_left,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              songTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              artistName,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isListening
                    ? const Color(0xFF10B981).withOpacity(0.15)
                    : const Color(0xFFEF4444).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isListening
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isListening ? LucideIcons.mic : LucideIcons.mic_off,
                    size: 14,
                    color: _isListening
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isListening ? "Listening" : "Stopped",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isListening
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _hasDetectedChord
                      ? const Color(0xFF10B981).withOpacity(0.2)
                      : (_detectedNote != "--"
                            ? const Color(0xFF0284C7).withOpacity(0.2)
                            : const Color(0xFF0F172A)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasDetectedChord
                        ? const Color(0xFF10B981)
                        : (_detectedNote != "--"
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF1E293B)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _hasDetectedChord
                              ? LucideIcons.circle_check
                              : LucideIcons.activity,
                          size: 16,
                          color: _hasDetectedChord
                              ? const Color(0xFF10B981)
                              : const Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _feedbackMessage,
                          style: TextStyle(
                            color: _hasDetectedChord
                                ? const Color(0xFF34D399)
                                : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _detectedNote != "--"
                          ? "${_detectedNote} (${_detectedPitch.toStringAsFixed(0)} Hz)"
                          : "--",
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B132B).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _hasDetectedChord
                          ? const Color(0xFF10B981)
                          : const Color(0xFF1E293B),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          painter: GuitarFretboardPainter(
                            diagramData:
                                _chordDiagrams[currentChord] ??
                                _chordDiagrams['C']!,
                          ),
                          child: Container(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "O",
                            style: TextStyle(
                              color: Color(0xFF22C55E),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            " = Open  •  ",
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "X",
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            " = Muted  •  Numbers = Fret Position",
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B132B).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1E293B),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Chord Progression",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_targetChords.length, (index) {
                          final isSelected = index == _currentChordIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentChordIndex = index;
                                _hasDetectedChord = false;
                                _detectedNote = "--";
                                _feedbackMessage = "Strum your guitar to play";
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF083344)
                                    : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF06B6D4)
                                      : const Color(0xFF1E293B),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                _targetChords[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF38BDF8)
                                      : const Color(0xFF94A3B8),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isPlayingSound
                          ? null
                          : () => _playChordAudio(currentChord),
                      icon: const Icon(LucideIcons.play, size: 16),
                      label: const Text("Play"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFF1E293B)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentChordIndex = 0;
                          _hasDetectedChord = false;
                          _correctAttempts = 0;
                          _incorrectAttempts = 0;
                          _elapsedSeconds = 0;
                          _detectedNote = "--";
                          _feedbackMessage = "Strum your guitar to play";
                        });
                      },
                      icon: const Icon(LucideIcons.rotate_ccw, size: 16),
                      label: const Text("Restart"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFF1E293B)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (_currentChordIndex < _targetChords.length - 1) {
                          setState(() {
                            _currentChordIndex++;
                            _hasDetectedChord = false;
                            _detectedNote = "--";
                            _feedbackMessage = "Strum your guitar to play";
                          });
                        } else {
                          _finishSession();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFF1E293B)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Next"),
                          SizedBox(width: 4),
                          Icon(LucideIcons.chevron_right, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _toggleListening,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _hasDetectedChord
                            ? [const Color(0xFF10B981), const Color(0xFF059669)]
                            : _isListening
                            ? [const Color(0xFF06B6D4), const Color(0xFFA855F7)]
                            : [
                                const Color(0xFF475569),
                                const Color(0xFF334155),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _hasDetectedChord
                                ? LucideIcons.circle_check
                                : _isListening
                                ? LucideIcons.mic
                                : LucideIcons.mic_off,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _hasDetectedChord
                                    ? "Chord Recognized!"
                                    : _isListening
                                    ? "Listening... (Tap to Stop)"
                                    : "Start Listening",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _hasDetectedChord
                                    ? "Moving to next chord..."
                                    : _isListening
                                    ? "Strum your guitar or tap to stop"
                                    : "Tap to enable microphone detection",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class ChordDiagramData {
  final List<String> stringStates;
  final List<FretDot> dots;

  ChordDiagramData({required this.stringStates, required this.dots});
}

class FretDot {
  final int stringIndex;
  final int fret;
  final String finger;

  FretDot({
    required this.stringIndex,
    required this.fret,
    required this.finger,
  });
}

class GuitarFretboardPainter extends CustomPainter {
  final ChordDiagramData diagramData;

  GuitarFretboardPainter({required this.diagramData});

  @override
  void paint(Canvas canvas, Size size) {
    final double topMargin = 40.0;
    final double bottomMargin = 30.0;
    final double leftMargin = 24.0;
    final double rightMargin = 24.0;

    final double boardWidth = size.width - leftMargin - rightMargin;
    final double boardHeight = size.height - topMargin - bottomMargin;

    final int numStrings = 6;
    final int numFrets = 5;

    final double stringSpacing = boardWidth / (numStrings - 1);
    final double fretSpacing = boardHeight / numFrets;

    final Paint gridPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1.5;

    final Paint nutPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 5.0;

    canvas.drawLine(
      Offset(leftMargin, topMargin),
      Offset(leftMargin + boardWidth, topMargin),
      nutPaint,
    );

    for (int i = 1; i <= numFrets; i++) {
      double y = topMargin + (i * fretSpacing);
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(leftMargin + boardWidth, y),
        gridPaint,
      );
    }

    final List<String> stringNames = ['E', 'A', 'D', 'G', 'B', 'E'];

    for (int i = 0; i < numStrings; i++) {
      double x = leftMargin + (i * stringSpacing);

      canvas.drawLine(
        Offset(x, topMargin),
        Offset(x, topMargin + boardHeight),
        gridPaint,
      );

      final TextPainter tpName = TextPainter(
        text: TextSpan(
          text: stringNames[i],
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpName.paint(
        canvas,
        Offset(x - (tpName.width / 2), topMargin + boardHeight + 8),
      );

      if (i < diagramData.stringStates.length) {
        String state = diagramData.stringStates[i];
        if (state == 'O') {
          final Paint openPaint = Paint()
            ..color = const Color(0xFF22C55E)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5;
          canvas.drawCircle(Offset(x, topMargin - 16), 7, openPaint);
        } else if (state == 'X') {
          final TextPainter tpX = TextPainter(
            text: const TextSpan(
              text: '✕',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tpX.paint(canvas, Offset(x - (tpX.width / 2), topMargin - 23));
        }
      }
    }

    for (var dot in diagramData.dots) {
      double x = leftMargin + (dot.stringIndex * stringSpacing);
      double y = topMargin + (dot.fret - 0.5) * fretSpacing;

      final Paint dotPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 14));

      canvas.drawCircle(Offset(x, y), 14, dotPaint);

      final TextPainter tpFinger = TextPainter(
        text: TextSpan(
          text: dot.finger,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpFinger.paint(
        canvas,
        Offset(x - (tpFinger.width / 2), y - (tpFinger.height / 2)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GuitarFretboardPainter oldDelegate) {
    return oldDelegate.diagramData != diagramData;
  }
}
