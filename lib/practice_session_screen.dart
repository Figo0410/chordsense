import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/api_service.dart';

class ChordConfig {
  final String name;
  final String difficulty;
  final Map<int, int> fingerFrets;
  final Map<int, String> fingerLabels;
  final List<int> openStrings;
  final List<double> targetFrequencies;

  ChordConfig({
    required this.name,
    required this.difficulty,
    required this.fingerFrets,
    required this.fingerLabels,
    required this.openStrings,
    required this.targetFrequencies,
  });
}

class PracticeSessionScreen extends StatefulWidget {
  final String initialChord;
  final String userId;
  final int levelId;
  final int rewardPoints;
  final List<String>? levelChords;
  final VoidCallback? onGoBack;

  PracticeSessionScreen({
    super.key,
    String? initialChord,
    String? targetChord,
    String? userId,
    int? levelId,
    int? levelNumber,
    this.rewardPoints = 100,
    this.levelChords,
    this.onGoBack,
  }) : initialChord = targetChord ?? initialChord ?? "C Major",
       userId = userId ?? "6a72a3418427dadc19d157d",
       levelId = levelNumber ?? levelId ?? 1;

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  final List<ChordConfig> _knownChords = [
    ChordConfig(
      name: "C Major",
      difficulty: "Easy",
      fingerFrets: {1: 3, 2: 2, 4: 1},
      fingerLabels: {1: "3", 2: "2", 4: "1"},
      openStrings: [1, 3, 5],
      targetFrequencies: [130.81, 164.81, 196.00, 261.63, 329.63],
    ),
    ChordConfig(
      name: "G Major",
      difficulty: "Easy",
      fingerFrets: {0: 3, 1: 2, 5: 3},
      fingerLabels: {0: "3", 1: "2", 5: "4"},
      openStrings: [2, 3, 4],
      targetFrequencies: [98.00, 123.47, 146.83, 196.00, 246.94, 392.00],
    ),
    ChordConfig(
      name: "D Major",
      difficulty: "Easy",
      fingerFrets: {3: 2, 4: 3, 5: 2},
      fingerLabels: {3: "1", 4: "3", 5: "2"},
      openStrings: [2],
      targetFrequencies: [146.83, 220.00, 293.66, 369.99],
    ),
    ChordConfig(
      name: "A Major",
      difficulty: "Easy",
      fingerFrets: {2: 2, 3: 2, 4: 2},
      fingerLabels: {2: "1", 3: "2", 4: "3"},
      openStrings: [1, 5],
      targetFrequencies: [110.00, 164.81, 220.00, 277.18, 329.63],
    ),
    ChordConfig(
      name: "A Minor",
      difficulty: "Easy",
      fingerFrets: {2: 2, 3: 2, 4: 1},
      fingerLabels: {2: "2", 3: "3", 4: "1"},
      openStrings: [1, 5],
      targetFrequencies: [110.00, 164.81, 220.00, 261.63, 329.63],
    ),
    ChordConfig(
      name: "E Minor",
      difficulty: "Easy",
      fingerFrets: {1: 2, 2: 2},
      fingerLabels: {1: "2", 2: "3"},
      openStrings: [0, 3, 4, 5],
      targetFrequencies: [82.41, 123.47, 164.81, 196.00, 246.94, 329.63],
    ),
    ChordConfig(
      name: "D Minor",
      difficulty: "Easy",
      fingerFrets: {3: 2, 4: 3, 5: 1},
      fingerLabels: {3: "2", 4: "3", 5: "1"},
      openStrings: [2],
      targetFrequencies: [146.83, 220.00, 293.66, 349.23],
    ),
  ];

  late List<ChordConfig> _chords;
  late ChordConfig _currentChord;
  int _currentChordIndex = 0;

  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  late PitchDetector _pitchDetector;

  int _totalAttempts = 0;
  int _correctAttempts = 0;
  int _incorrectAttempts = 0;
  final int _requiredAttempts = 1;

  int _accuracy = 0;
  int _points = 0;
  DateTime? _sessionStartTime;

  bool _isListening = false;
  bool _isProcessingAudio = false;
  bool _isCountingDown = false;
  int _countdown = 3;
  double _lastDetectedPitch = 0.0;
  String _feedbackMessage = "Position your fingers and tap 'Start Practice'";
  bool _showSuccessFeedback = false;
  bool _showErrorFeedback = false;
  bool _showPointsToast = false;

  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _setupLevelChordsQueue();
    _pitchDetector = PitchDetector();
    _sessionStartTime = DateTime.now();
  }

  void _setupLevelChordsQueue() {
    List<String> targetChordNames = widget.levelChords ?? [widget.initialChord];
    if (targetChordNames.isEmpty) {
      targetChordNames = [widget.initialChord];
    }

    _chords = targetChordNames.map((chordName) {
      return _knownChords.firstWhere(
        (c) => c.name.toLowerCase() == chordName.toLowerCase(),
        orElse: () => ChordConfig(
          name: chordName,
          difficulty: "Easy",
          fingerFrets: {1: 2, 2: 2},
          fingerLabels: {1: "1", 2: "2"},
          openStrings: [0, 3, 4, 5],
          targetFrequencies: [110.00, 164.81, 220.00, 261.63, 329.63],
        ),
      );
    }).toList();

    _currentChordIndex = 0;
    _currentChord = _chords[_currentChordIndex];
  }

  @override
  void dispose() {
    _stopListeningSync();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startPracticeFlow() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Microphone permission is required for audio analysis.',
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isCountingDown = true;
      _countdown = 3;
      _feedbackMessage = "Get Ready...";
      _showSuccessFeedback = false;
      _showErrorFeedback = false;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
          _feedbackMessage = "Listening... Play the chord!";
        });
        _startListening();
      }
    });
  }

  void _startListening() async {
    try {
      if (_isListening) return;

      await _audioCapture.init();
      await _audioCapture.start(
        _onAudioData,
        _onError,
        sampleRate: 44100,
        bufferSize: 2048,
      );

      if (mounted) {
        setState(() {
          _isListening = true;
          _isProcessingAudio = false;
        });
      }
    } catch (e) {
      debugPrint("Error starting audio listener: $e");
      if (mounted) {
        setState(() {
          _isListening = false;
          _isProcessingAudio = false;
        });
      }
    }
  }

  void _stopListeningSync() {
    _isListening = false;
    _audioCapture.stop().catchError((e) => debugPrint("Stop error: $e"));
  }

  void _onAudioData(dynamic obj) async {
    if (!_isListening || _isProcessingAudio || !mounted) return;

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
        _isProcessingAudio = true;
        _stopListeningSync();
        _processFrequency(result.pitch);
      }
    } catch (e) {
      debugPrint("Pitch detection error: $e");
    }
  }

  void _onError(Object e) {
    debugPrint("Audio Capture Error: $e");
  }

  void _processFrequency(double detectedPitch) {
    bool isMatch = _evaluateChordMatch(
      detectedPitch,
      _currentChord.targetFrequencies,
    );

    setState(() {
      _totalAttempts++;
      _lastDetectedPitch = detectedPitch;

      if (isMatch) {
        _correctAttempts++;
        _points += 20;
        _showSuccessFeedback = true;
        _showPointsToast = true;
        _feedbackMessage = "Correct! Chord saved.";
      } else {
        _incorrectAttempts++;
        _showErrorFeedback = true;
        _feedbackMessage = "Try Again! Check finger placement and strum again.";
      }

      _accuracy = ((_correctAttempts / _totalAttempts) * 100).round();
    });

    if (isMatch) {
      _saveSingleChordProgress(_currentChord.name);
    }

    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _showPointsToast = false);
    });

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (isMatch && _correctAttempts >= _requiredAttempts) {
        if (_currentChordIndex < _chords.length - 1) {
          setState(() {
            _currentChordIndex++;
            _currentChord = _chords[_currentChordIndex];
            _correctAttempts = 0;
            _showSuccessFeedback = false;
            _feedbackMessage = "Next Chord: ${_currentChord.name}!";
          });
          _startPracticeFlow();
        } else {
          _completeLevel();
        }
      } else {
        setState(() {
          _showSuccessFeedback = false;
          _showErrorFeedback = false;
          _isProcessingAudio = false;
        });
      }
    });
  }

  Future<void> _updateProfileHelper(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await ApiService.updateUserProfile(userId, data);
    } catch (e) {
      debugPrint("User Profile Update Notice: $e");
    }
  }

  void _saveSingleChordProgress(String chordName) async {
    final durationInSeconds = DateTime.now()
        .difference(_sessionStartTime!)
        .inSeconds;

    double progressFraction = (_currentChordIndex + 1) / _chords.length;
    int currentProgressPercent = (progressFraction * 100).round();

    try {
      await ApiService.savePracticeSession(
        userId: widget.userId,
        levelId: widget.levelId,
        chordPracticed: chordName,
        totalAttempts: _totalAttempts,
        correctAttempts: _correctAttempts,
        incorrectAttempts: _incorrectAttempts,
        accuracy: _accuracy,
        pointsEarned: 20,
        duration: durationInSeconds,
      );

      await _updateProfileHelper(widget.userId, {
        "completedChords": [chordName],
        "progressPercent": currentProgressPercent,
        "totalPoints": _points,
      });
    } catch (e) {
      debugPrint("Incremental Chord Progress Save Notice: $e");
    }
  }

  bool _evaluateChordMatch(double detected, List<double> targets) {
    for (double target in targets) {
      if ((detected - target).abs() <= 12.0) return true;
      if ((detected - (target * 2)).abs() <= 12.0 ||
          (detected - (target / 2)).abs() <= 12.0) {
        return true;
      }
    }
    return false;
  }

  void _completeLevel() async {
    final durationInSeconds = DateTime.now()
        .difference(_sessionStartTime!)
        .inSeconds;

    int totalEarnedPoints = _points + widget.rewardPoints;
    String allChordsStr = _chords.map((c) => c.name).join(", ");

    try {
      await ApiService.savePracticeSession(
        userId: widget.userId,
        levelId: widget.levelId,
        chordPracticed: allChordsStr,
        totalAttempts: _totalAttempts,
        correctAttempts: _correctAttempts,
        incorrectAttempts: _incorrectAttempts,
        accuracy: _accuracy,
        pointsEarned: totalEarnedPoints,
        duration: durationInSeconds,
      );

      await _updateProfileHelper(widget.userId, {
        "completed": true,
        "levelNumber": widget.levelId,
        "accuracy": _accuracy,
        "completedLevels": [
          {
            "levelNumber": widget.levelId,
            "progress": 1.0,
            "accuracy": _accuracy,
          },
        ],
        "completedChords": _chords.map((c) => c.name).toList(),
        "currentLevel": widget.levelId + 1,
        "progressPercent": 100,
      });
    } catch (e) {
      debugPrint("Level completion sync notice: $e");
    }

    if (!mounted) return;

    _showCompletionDialog(totalEarnedPoints);
  }

  void _showCompletionDialog(int totalEarnedPoints) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF1E293B), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.trophy,
                    color: Color(0xFF10B981),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Level Completed!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Congratulations! You've successfully finished Level ${widget.levelId}.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF030712),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Points Earned",
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "+$totalEarnedPoints",
                            style: const TextStyle(
                              color: Color(0xFFA855F7),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: const Color(0xFF1E293B),
                      ),
                      Column(
                        children: [
                          const Text(
                            "Accuracy",
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$_accuracy%",
                            style: const TextStyle(
                              color: Color(0xFF22D3EE),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        widget.onGoBack?.call();
                      }
                    },
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrow_left,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              widget.onGoBack?.call();
            }
          },
        ),
        title: Text(
          "Level ${widget.levelId} Practice",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTopMetric(
                      "Accuracy",
                      "$_accuracy%",
                      const Color(0xFF22D3EE),
                    ),
                    _buildTopMetric(
                      "Points",
                      "$_points",
                      const Color(0xFFA855F7),
                    ),
                    _buildTopMetric(
                      "Progress",
                      "${_currentChordIndex + _correctAttempts}/${_chords.length}",
                      Colors.white70,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "Chord ${_currentChordIndex + 1} of ${_chords.length}",
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _currentChord.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentChord.difficulty,
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildChordFretboard(),
                const SizedBox(height: 20),
                _buildBottomActionArea(),
              ],
            ),
          ),
          _buildPointsToast(),
        ],
      ),
    );
  }

  Widget _buildTopMetric(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChordFretboard() {
    return Container(
      width: double.infinity,
      height: 380,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double boardWidth = constraints.maxWidth * 0.8;
                final double boardHeight = constraints.maxHeight * 0.85;
                final double stringSpacing = boardWidth / 5;
                final double fretSpacing = boardHeight / 5;

                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: boardWidth,
                      height: boardHeight,
                      margin: const EdgeInsets.only(top: 30),
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              6,
                              (index) => Container(
                                width: 1.5,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              6,
                              (index) => Container(
                                height: index == 0 ? 4 : 1.5,
                                color: index == 0
                                    ? Colors.white70
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 2,
                      left: (constraints.maxWidth - boardWidth) / 2 - 8,
                      right: (constraints.maxWidth - boardWidth) / 2 - 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          final isOpen = _currentChord.openStrings.contains(
                            index,
                          );
                          return SizedBox(
                            width: 16,
                            height: 16,
                            child: isOpen
                                ? const Center(
                                    child: Text(
                                      "O",
                                      style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          );
                        }),
                      ),
                    ),
                    ..._currentChord.fingerFrets.entries.map((entry) {
                      final stringIndex = entry.key;
                      final fretNumber = entry.value;
                      final label =
                          _currentChord.fingerLabels[stringIndex] ?? "1";
                      final double leftPos =
                          ((constraints.maxWidth - boardWidth) / 2) +
                          (stringIndex * stringSpacing) -
                          14;
                      final double topPos =
                          30 +
                          (fretNumber * fretSpacing) -
                          (fretSpacing / 2) -
                          14;

                      return Positioned(
                        left: leftPos,
                        top: topPos,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF8B5CF6,
                                ).withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "E",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "A",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "D",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "G",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "B",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "E",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "O",
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                " = Open  •  ",
                style: TextStyle(color: Color(0xFF475569), fontSize: 10),
              ),
              Text(
                "X",
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                " = Muted  •  Numbers = Fret Position",
                style: TextStyle(color: Color(0xFF475569), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionArea() {
    if (_showSuccessFeedback) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF042F1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981), width: 1.5),
        ),
        child: Column(
          children: [
            const Icon(
              LucideIcons.circle_check,
              color: Color(0xFF10B981),
              size: 36,
            ),
            const SizedBox(height: 8),
            const Text(
              "Correct!",
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Detected pitch: ${_lastDetectedPitch.toStringAsFixed(1)} Hz",
              style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (_showErrorFeedback) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF450A0A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
        ),
        child: Column(
          children: [
            const Icon(
              LucideIcons.circle_x,
              color: Color(0xFFEF4444),
              size: 36,
            ),
            const SizedBox(height: 8),
            const Text(
              "Try Again",
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _feedbackMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_isCountingDown)
          Text(
            "$_countdown",
            style: const TextStyle(
              color: Color(0xFF0EA5E9),
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 8),
        Container(
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF8B5CF6)],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: (_isListening || _isCountingDown)
                  ? null
                  : _startPracticeFlow,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isListening
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            LucideIcons.mic,
                            color: Colors.white,
                            size: 16,
                          ),
                    const SizedBox(width: 8),
                    Text(
                      _isListening
                          ? "Listening to Guitar..."
                          : (_isCountingDown
                                ? "Get Ready..."
                                : "Start Practice"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsToast() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: _showPointsToast ? 90 : -80,
      right: 20,
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF1F5F9),
              ),
              child: const Icon(
                LucideIcons.circle_check,
                color: Colors.black,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "+20 points!",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Chord Saved!",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
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
