import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart'; // Or use standard Lucide icons based on your setup

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
  const TunerScreen({super.key});

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen> {
  // 1. Acoustic Guitar Standard Frequencies (Highly Accurate)
  final List<GuitarString> _strings = [
    GuitarString(number: 1, noteName: "E", label: "High E", frequency: 329.63),
    GuitarString(number: 2, noteName: "B", label: "B", frequency: 246.94),
    GuitarString(number: 3, noteName: "G", label: "G", frequency: 196.00),
    GuitarString(number: 4, noteName: "D", label: "D", frequency: 146.83),
    GuitarString(number: 5, noteName: "A", label: "A", frequency: 110.00),
    GuitarString(number: 6, noteName: "E", label: "Low E", frequency: 82.41),
  ];

  int _selectedStringIndex = 0; // Starts with High E active
  bool _isListening = true;

  // Simulated deviation value (-50 to +50 cents range)
  // 0 is "PERFECT". The image shows +4.0 cents (slightly sharp)
  double _currentDeviation = 4.0;

  int get _tunedCount => _strings.where((s) => s.isTuned).length;

  @override
  Widget build(BuildContext context) {
    final activeString = _strings[_selectedStringIndex];

    // Determine tuning state string based on deviation
    String statusText = "TUNING...";
    Color statusColor = Colors.white;
    if (_isListening) {
      if (_currentDeviation.abs() <= 2.0) {
        statusText = "✓ IN TUNE";
        statusColor = const Color(0xFF10B981); // Emerald Green
      } else if (_currentDeviation < -2.0) {
        statusText = "TOO FLAT";
        statusColor = const Color(0xFFEF4444); // Red
      } else {
        statusText = "TOO SHARP";
        statusColor = const Color(0xFFF97316); // Orange
      }
    } else {
      statusText = "PAUSED";
      statusColor = const Color(0xFF64748B);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF030712), // Deep slate-950 base
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
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.volume_2, color: Color(0xFF818CF8)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          100,
        ), // Extra bottom padding for floating bar overlap
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HOW TO USE BANNER ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF071B2F), // Dark blue tint
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
                          "Tap a string below, then play that string on your guitar. The tuner will detect the pitch and show if it's in tune.",
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

            // --- 2. TUNER CALIBRATION BOARD (THE METRIC BAR) ---
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isListening && _currentDeviation.abs() <= 2.0
                      ? const Color(0xFF10B981) // Green border if perfect
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
                    "${activeString.label} (${activeString.noteName})",
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // The Needle Slider Bar
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Map deviation (-50 to +50 cents) to a normalized fraction (0.0 to 1.0)
                      double normalizedValue = ((_currentDeviation + 50) / 100)
                          .clamp(0.0, 1.0);
                      double needlePosition =
                          constraints.maxWidth * normalizedValue;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Base horizontal bar gradient background
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
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            left: Radius.circular(12),
                                          ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  color: Colors.green.withOpacity(0.1),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
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

                          // Perfect Center Marker Block
                          Container(
                            width: 3,
                            height: 30,
                            color: const Color(0xFF64748B),
                          ),

                          // Floating Needle indicator
                          Positioned(
                            left:
                                needlePosition -
                                6, // Centered on calculated spot
                            child: Container(
                              width: 12,
                              height: 28,
                              decoration: BoxDecoration(
                                color:
                                    _isListening &&
                                        _currentDeviation.abs() <= 2.0
                                    ? const Color(0xFF10B981) // Green
                                    : const Color(0xFFF97316), // Orange
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_currentDeviation.abs() <= 2.0
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFF97316))
                                            .withOpacity(0.5),
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

                  // Cents Indicators
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

                  // Deviation Label
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

            // --- 3. THE 6-STRING LIST VIEW ---
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
                      // Simulate different pitches when clicking through strings
                      if (index == 0)
                        _currentDeviation =
                            4.0; // Slightly sharp (matching original image)
                      if (index == 1) _currentDeviation = -12.5; // Flat
                      if (index == 2) _currentDeviation = 0.0; // Perfect
                      if (index == 3) _currentDeviation = 1.2; // Perfect
                      if (index >= 4) _currentDeviation = -6.0;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.4),
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
                            // Circular Indicator Number
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFF0284C7).withOpacity(0.15)
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
                            // String Label & Frequency Info
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
                        // Right-Hand Status Indicator
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

            // --- 4. START/STOP LISTENING BUTTON ---
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
                  setState(() {
                    _isListening = !_isListening;
                  });
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

            // --- 5. TUNING PROGRESS BANNER ---
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF011A13), // Deep dark green shade
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

                  // Segmented String Progress Bar (6 Custom Slots)
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

                  // Mark Active String as Tuned (Helps simulate progression)
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
                      onPressed: () {
                        setState(() {
                          _strings[_selectedStringIndex].isTuned =
                              !_strings[_selectedStringIndex].isTuned;
                        });
                      },
                      icon: const Icon(
                        LucideIcons.check,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                      label: const Text(
                        "Mark as Tuned",
                        style: TextStyle(
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
            const SizedBox(height: 18),

            // --- 6. TUNING TIPS CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.lightbulb,
                        color: Color(0xFFEAB308),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Tuning Tips",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  BulletPoint(
                    text: "Turn the tuning peg slowly for precise adjustments",
                  ),
                  BulletPoint(
                    text:
                        "If too flat, tighten the string by turning clockwise",
                  ),
                  BulletPoint(
                    text:
                        "If too sharp, loosen the string by turning counter-clockwise",
                  ),
                  BulletPoint(
                    text: "Always tune in a quiet environment for best results",
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

// Custom bullet-point helper for cleanly laid out advice lines
class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(color: Color(0xFF0EA5E9), fontSize: 14),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
