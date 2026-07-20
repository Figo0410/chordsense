import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ChordData {
  final String name;
  final String lyric;
  // List of string statuses from String 6 (E-low) to String 1 (E-high): 'O' = Open, 'X' = Muted, '' = Fretted
  final List<String> topIndicators;
  // Map of stringIndex (0-5) to fret number (1-4) and finger number
  final Map<int, Map<String, int>> fingerPositions;

  ChordData({
    required this.name,
    required this.lyric,
    required this.topIndicators,
    required this.fingerPositions,
  });
}

class GuidedPlayScreen extends StatefulWidget {
  final String songTitle;
  final String artist;

  const GuidedPlayScreen({
    super.key,
    this.songTitle = "Alapaap",
    this.artist = "Eraserheads",
  });

  @override
  State<GuidedPlayScreen> createState() => _GuidedPlayScreenState();
}

class _GuidedPlayScreenState extends State<GuidedPlayScreen> {
  int _currentIndex = 0;
  bool _isSuccessState = false;

  // Sample progression data for Alapaap matching the screenshots
  final List<ChordData> _chords = [
    ChordData(
      name: "G",
      lyric: '"Walang nagawa..."',
      topIndicators: ['', 'O', 'O', 'O', '', ''],
      fingerPositions: {
        0: {'fret': 3, 'finger': 3},
        1: {'fret': 2, 'finger': 2},
        5: {'fret': 3, 'finger': 3},
      },
    ),
    ChordData(
      name: "D",
      lyric: '"kundi ang makinig..."',
      topIndicators: ['', '', 'O', 'X', 'X', ''],
      fingerPositions: {
        0: {'fret': 2, 'finger': 2},
        1: {'fret': 3, 'finger': 3},
        3: {'fret': 2, 'finger': 2},
      },
    ),
    ChordData(
      name: "Em",
      lyric: '"sa mga bulong..."',
      topIndicators: ['O', '', '', 'O', 'O', 'O'],
      fingerPositions: {
        1: {'fret': 2, 'finger': 2},
        2: {'fret': 2, 'finger': 3},
      },
    ),
    ChordData(
      name: "C",
      lyric: '"ng hangin..."',
      topIndicators: ['X', '', '', 'O', '', 'O'],
      fingerPositions: {
        1: {'fret': 3, 'finger': 3},
        2: {'fret': 2, 'finger': 2},
        4: {'fret': 1, 'finger': 1},
      },
    ),
  ];

  void _handleDetectChord() async {
    setState(() {
      _isSuccessState = true;
    });

    // Automatically transition to the next chord after a short success display
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSuccessState = false;
        if (_currentIndex < _chords.length - 1) {
          _currentIndex++;
        }
      });
    }
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _isSuccessState = false;
    });
  }

  void _nextChord() {
    if (_currentIndex < _chords.length - 1) {
      setState(() {
        _currentIndex++;
        _isSuccessState = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChord = _chords[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrow_left,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              widget.songTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.artist,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          "Now Playing",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentChord.name,
                          style: const TextStyle(
                            color: Color(0xFF818CF8),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentChord.lyric,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFretboardCard(currentChord),
                        const SizedBox(height: 16),
                        if (_isSuccessState) _buildSuccessBanner(),
                        const SizedBox(height: 16),
                        _buildProgressionCard(),
                        const SizedBox(height: 16),
                        _buildControlButtons(),
                        const SizedBox(height: 16),
                        if (!_isSuccessState) _buildPlayChordButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isSuccessState) _buildBottomToast(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final double progressPercent = (_currentIndex + 1) / _chords.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Progress",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
              Text(
                "${_currentIndex + 1} / ${_chords.length}",
                style: const TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 4,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF0284C7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFretboardCard(ChordData chord) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          // Top Open/Muted indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              final indicator = chord.topIndicators[index];
              return SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: indicator == 'O'
                      ? const Icon(
                          Icons.circle_outlined,
                          color: Color(0xFF22C55E),
                          size: 20,
                        )
                      : indicator == 'X'
                      ? const Icon(
                          Icons.close,
                          color: Color(0xFFEF4444),
                          size: 20,
                        )
                      : const SizedBox.shrink(),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Interactive Fretboard Grid
          Container(
            height: 220,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white, width: 4), // Guitar Nut
              ),
            ),
            child: Stack(
              children: [
                // Fret Lines
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (_) => const Divider(
                      color: Color(0xFF334155),
                      height: 1,
                      thickness: 1.5,
                    ),
                  ),
                ),
                // String Lines & Finger Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (stringIdx) {
                    final pos = chord.fingerPositions[stringIdx];
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(width: 1.5, color: const Color(0xFF475569)),
                        if (pos != null)
                          Positioned(
                            top: (pos['fret']! - 1) * 52.0 + 12.0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF06B6D4),
                                    Color(0xFFA855F7),
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(0xFF38BDF8),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF06B6D4,
                                    ).withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "${pos['finger']}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // String Names Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text(
                "E",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                "A",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                "D",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                "G",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                "B",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                "E",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.circle_outlined, color: Color(0xFFEF4444), size: 10),
              SizedBox(width: 4),
              Text(
                "= Open  •  ",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
              Text(
                "X",
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              SizedBox(width: 4),
              Text(
                "= Muted  •  Numbers = Fret Position",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF022C22).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF059669)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.check, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          const Text(
            "Perfect!",
            style: TextStyle(
              color: Color(0xFF34D399),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chord Progression",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_chords.length, (idx) {
              final isSelected = idx == _currentIndex;
              final isCompleted =
                  idx < _currentIndex ||
                  (idx == _currentIndex && _isSuccessState);

              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF064E3B).withOpacity(0.4)
                      : isSelected
                      ? const Color(0xFF082F49)
                      : const Color(0xFF1E293B).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF059669)
                        : isSelected
                        ? const Color(0xFF0EA5E9)
                        : const Color(0xFF334155),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _chords[idx].name,
                      style: TextStyle(
                        color: isCompleted
                            ? const Color(0xFF34D399)
                            : isSelected
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(height: 2),
                      const Icon(
                        LucideIcons.check,
                        color: Color(0xFF34D399),
                        size: 10,
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.play, size: 14, color: Colors.white),
            label: const Text(
              "Play",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFF1E293B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _restart,
            icon: const Icon(
              LucideIcons.rotate_ccw,
              size: 14,
              color: Colors.white,
            ),
            label: const Text(
              "Restart",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFF1E293B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _nextChord,
            icon: const Text(
              "Next",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            label: const Icon(
              LucideIcons.chevron_right,
              size: 14,
              color: Colors.white,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFF1E293B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayChordButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _handleDetectChord,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA855F7).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(LucideIcons.volume_2, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Play This Chord",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Tap to detect your playing",
                      style: TextStyle(color: Colors.white70, fontSize: 10),
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

  Widget _buildBottomToast() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(LucideIcons.circle_check, color: Colors.black, size: 18),
            SizedBox(width: 8),
            Text(
              "Perfect! Moving to next chord...",
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
