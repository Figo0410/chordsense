import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

// Model to represent different chord structures for dynamic rendering
class ChordConfig {
  final String name;
  final String difficulty;
  // String index (0 = Low E, 5 = High E) -> Fret position (1-based)
  final Map<int, int> fingerFrets;
  // String index -> Finger number label
  final Map<int, String> fingerLabels;
  // Open strings (indices that display 'O')
  final List<int> openStrings;

  ChordConfig({
    required this.name,
    required this.difficulty,
    required this.fingerFrets,
    required this.fingerLabels,
    required this.openStrings,
  });
}

class PracticeSessionScreen extends StatefulWidget {
  final String initialChord;
  const PracticeSessionScreen({super.key, this.initialChord = "C Major"});

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  // Available Chords in Level 1 for progression
  final List<ChordConfig> _chords = [
    ChordConfig(
      name: "C Major",
      difficulty: "Easy",
      fingerFrets: {
        1: 3,
        2: 2,
        4: 1,
      }, // A string: Fret 3, D string: Fret 2, B string: Fret 1
      fingerLabels: {1: "3", 2: "2", 4: "1"},
      openStrings: [1, 3, 5], // A, G, High E
    ),
    ChordConfig(
      name: "G Major",
      difficulty: "Easy",
      fingerFrets: {
        0: 3,
        1: 2,
        5: 3,
      }, // Low E: Fret 3, A string: Fret 2, High E: Fret 3
      fingerLabels: {0: "3", 1: "2", 5: "4"},
      openStrings: [2, 3, 4], // D, G, B
    ),
  ];

  late ChordConfig _currentChord;
  int _currentChordIndex = 0;

  // Session Stats
  int _accuracy = 0;
  int _points = 0;
  int _currentProgress = 0;
  int _totalProgress = 2;

  // Flow control states
  bool _isDetecting = false;
  bool _showPerfectFeedback = false;
  bool _showPointsToast = false;

  @override
  void initState() {
    super.initState();
    _currentChord = _chords.firstWhere(
      (c) => c.name.toLowerCase() == widget.initialChord.toLowerCase(),
      orElse: () => _chords[0],
    );
    _currentChordIndex = _chords.indexOf(_currentChord);
  }

  void _startDetection() {
    setState(() {
      _isDetecting = true;
    });

    // Simulate real-time audio detection algorithm listening to the guitar pitch
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isDetecting = false;
        _showPerfectFeedback = true;
        _showPointsToast = true;

        // Update stats matching image 2
        _accuracy = 50;
        _points = 50;
        _currentProgress = 1;
      });

      // Hide the bottom-right points toast after 3 seconds
      Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() => _showPointsToast = false);
      });

      // Proceed smoothly to the next chord (G Major) after showing feedback
      Timer(const Duration(seconds: 4), () {
        if (!mounted) return;
        setState(() {
          _showPerfectFeedback = false;
          _currentChordIndex = (_currentChordIndex + 1) % _chords.length;
          _currentChord = _chords[_currentChordIndex];
          // Reset progress count to demonstrate infinite loop/refresh
          if (_currentChordIndex == 0) {
            _accuracy = 0;
            _points = 0;
            _currentProgress = 0;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712), // Deep dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrow_left,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Practice Session",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // --- 1. TOP METRICS HEADER ---
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
                      "$_currentProgress/$_totalProgress",
                      Colors.white70,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // --- 2. CHORD LABELS ---
                const Text(
                  "Now Playing",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
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
                const SizedBox(height: 24),

                // --- 3. GUITAR CHORD FRETBOARD DIAGRAM ---
                Expanded(child: _buildChordFretboard()),
                const SizedBox(height: 20),

                // --- 4. BOTTOM ACTION CONTROL / FEEDBACK BOX ---
                _buildBottomActionArea(),
                const SizedBox(height: 36),
              ],
            ),
          ),

          // --- 5. POPUP TOAST IN BOTTOM RIGHT (+50 points!) ---
          _buildPointsToast(),
        ],
      ),
    );
  }

  // Helper to build header statistics
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

  // Beautiful Fretboard Renderer using simple, precise stack metrics matching the diagram layout
  Widget _buildChordFretboard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.2),
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
                    // Grid Backplate - Verticals (Strings) and Horizontals (Frets)
                    Container(
                      width: boardWidth,
                      height: boardHeight,
                      margin: const EdgeInsets.only(top: 30),
                      child: Stack(
                        children: [
                          // 6 Strings (vertical grid lines)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return Container(
                                width: 1.5,
                                color: const Color(0xFF334155),
                              );
                            }),
                          ),
                          // 5 Frets (horizontal lines)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return Container(
                                height: index == 0
                                    ? 4
                                    : 1.5, // Thick white nut at the top
                                color: index == 0
                                    ? Colors.white70
                                    : const Color(0xFF334155),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    // Open String "O" Indicators (Placed above the white nut)
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

                    // Positioned Finger Dots on the Grid
                    ..._currentChord.fingerFrets.entries.map((entry) {
                      final stringIndex = entry.key; // 0 to 5
                      final fretNumber = entry.value; // 1 to 5
                      final label =
                          _currentChord.fingerLabels[stringIndex] ?? "1";

                      // Calculations to center the dots exactly over intersecting grid lines
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
                                color: const Color(0xFF8B5CF6).withOpacity(0.5),
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

          // String Tuning Labels (E, A, D, G, B, E) matching bottom of image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
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

          // Custom Legend text row
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "O",
                style: TextStyle(
                  color: Color(0xFFEF4444),
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

  // Dynamic layout changes based on user action states
  Widget _buildBottomActionArea() {
    if (_showPerfectFeedback) {
      // Perfect green status container (Image 2)
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF042F1A), // Deep forest green
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981), width: 1.5),
        ),
        child: Column(
          children: const [
            Icon(LucideIcons.circle_check, color: Color(0xFF10B981), size: 36),
            SizedBox(height: 8),
            Text(
              "Perfect!",
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Great job! Moving to next chord...",
              style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 12),
            ),
          ],
        ),
      );
    }

    // Standard detection CTA button (Image 1)
    return Container(
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _isDetecting ? null : _startDetection,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isDetecting
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isDetecting ? "Listening..." : "Start Detection",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Text(
                      "Play the chord",
                      style: TextStyle(color: Colors.white70, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Floating bottom-right badge mimicking custom snackbars/toasts
  Widget _buildPointsToast() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: _showPointsToast ? 24 : -80,
      right: 20,
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "+50 points!",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Perfect chord!",
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
