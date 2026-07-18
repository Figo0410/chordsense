import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'practice_session_screen.dart'; // Import  PracticeSessionScreen widget

class LevelData {
  final int levelNumber;
  final String title;
  final String difficulty; // Beginner, Intermediate, etc.
  final List<String> chords;
  final int requiredPoints;
  final int rewardPoints;
  final double? progress; // null means locked, 1.0 means completed
  final int? accuracy; // e.g., 92%

  LevelData({
    required this.levelNumber,
    required this.title,
    required this.difficulty,
    required this.chords,
    required this.requiredPoints,
    required this.rewardPoints,
    this.progress,
    this.accuracy,
  });
}

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  final List<String> _filters = [
    "All",
    "Beginner",
    "Intermediate",
    "Advanced",
    "Master",
  ];
  String _selectedFilter = "All";

  // Mock data representing your exact learning path progression
  final List<LevelData> _levels = [
    LevelData(
      levelNumber: 1,
      title: "Basic Foundation",
      difficulty: "Beginner",
      chords: ["C Major", "G Major"],
      requiredPoints: 0,
      rewardPoints: 100,
      progress: 1.0,
      accuracy: 92,
    ),
    LevelData(
      levelNumber: 2,
      title: "Major Chords",
      difficulty: "Beginner",
      chords: ["D Major", "A Major"],
      requiredPoints: 100,
      rewardPoints: 150,
      progress: 1.0,
      accuracy: 88,
    ),
    LevelData(
      levelNumber: 3,
      title: "Minor Chords",
      difficulty: "Beginner",
      chords: ["A Minor", "E Minor", "D Minor"],
      requiredPoints: 250,
      rewardPoints: 200,
      progress: 0.65,
    ),
    LevelData(
      levelNumber: 4,
      title: "Chord Transitions",
      difficulty: "Intermediate",
      chords: ["C-G-D Transition", "Am-Em Switch"],
      requiredPoints: 450,
      rewardPoints: 250,
      progress: 0.0,
    ),
    LevelData(
      levelNumber: 5,
      title: "Bar Chords",
      difficulty: "Intermediate",
      chords: ["F Major", "Bm"],
      requiredPoints: 700,
      rewardPoints: 300,
      progress: null, // Locked
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter levels based on selected difficulty category
    final filteredLevels = _levels.where((level) {
      if (_selectedFilter == "All") return true;
      return level.difficulty.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF030712), // Dark Slate base
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Learning Path",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Structured chord progression journey",
              style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // --- 1. USER METRICS DISPLAY ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    "Your Points",
                    "3450",
                    const Color(0xFFA855F7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    "Levels Completed",
                    "2/10",
                    const Color(0xFF0EA5E9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- 2. HORIZONTAL FILTER BUTTONS ---
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                            )
                          : null,
                      color: isSelected ? null : const Color(0xFF0F172A),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // --- 3. LEVEL CARD LIST ---
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: filteredLevels.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildLevelCard(filteredLevels[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Header metric card helper
  Widget _buildMetricCard(String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Large Interactive Level Card Builder
  Widget _buildLevelCard(LevelData level) {
    final bool isLocked = level.progress == null;
    final bool isCompleted = level.progress == 1.0;

    // Outer border color adjustments
    Color cardBorderColor = const Color(0xFF1E293B);
    if (isCompleted) {
      cardBorderColor = const Color(
        0xFF10B981,
      ).withOpacity(0.4); // Emerald Green
    } else if (!isLocked && level.progress! > 0.0) {
      cardBorderColor = const Color(0xFF0EA5E9).withOpacity(0.4); // Cyan Blue
    }

    return Container(
      decoration: BoxDecoration(
        color: isLocked
            ? const Color(0xFF0B1222).withOpacity(0.4)
            : const Color(0xFF0F172A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left hand Icon Badge (Checked / Number / Locked)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : (isLocked
                              ? const Color(0xFF1E293B).withOpacity(0.3)
                              : const Color(0xFF0284C7).withOpacity(0.1)),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFF10B981)
                          : (isLocked
                                ? const Color(0xFF334155)
                                : const Color(0xFF0284C7)),
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            LucideIcons.circle_check,
                            color: Color(0xFF10B981),
                            size: 20,
                          )
                        : (isLocked
                              ? const Icon(
                                  LucideIcons.lock,
                                  color: Color(0xFF475569),
                                  size: 18,
                                )
                              : Text(
                                  "${level.levelNumber}",
                                  style: const TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                  ),
                ),
                const SizedBox(width: 14),

                // Level Headers
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Level ${level.levelNumber}: ${level.title}",
                            style: TextStyle(
                              color: isLocked
                                  ? const Color(0xFF475569)
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isCompleted && level.accuracy != null)
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.star,
                                  color: Color(0xFF10B981),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${level.accuracy}%",
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Difficulty Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLocked
                              ? const Color(0xFF1E293B)
                              : (level.difficulty == "Beginner"
                                    ? const Color(0xFF064E3B)
                                    : const Color(0xFF78350F)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          level.difficulty,
                          style: TextStyle(
                            color: isLocked
                                ? const Color(0xFF64748B)
                                : (level.difficulty == "Beginner"
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B)),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Chords pill block
            const Text(
              "Chords to Learn:",
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: level.chords.map((chord) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isLocked
                        ? const Color(0xFF1E293B).withOpacity(0.4)
                        : const Color(0xFF0C243B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isLocked
                          ? const Color(0xFF334155)
                          : const Color(0xFF0C4A6E),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.music,
                        color: isLocked
                            ? const Color(0xFF475569)
                            : const Color(0xFF0EA5E9),
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        chord,
                        style: TextStyle(
                          color: isLocked
                              ? const Color(0xFF475569)
                              : const Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Points Info & Mid-level stats row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Required Points",
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${level.requiredPoints}",
                        style: TextStyle(
                          color: isLocked
                              ? const Color(0xFF475569)
                              : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Reward",
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "+${level.rewardPoints} pts",
                        style: TextStyle(
                          color: isLocked
                              ? const Color(0xFF475569)
                              : const Color(0xFFD946EF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLocked && !isCompleted && level.progress != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Progress",
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${(level.progress! * 100).toInt()}%",
                          style: const TextStyle(
                            color: Color(0xFF0EA5E9),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Non-completed progress slider bar
            if (!isLocked && !isCompleted && level.progress != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: level.progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1E293B),
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Bottom CTA Buttons (Review / Practice / Locked)
            if (isCompleted)
              _buildActionButton(
                label: "Review Level",
                icon: LucideIcons.arrow_right,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PracticeSessionScreen(
                        initialChord: level.chords.first,
                      ),
                    ),
                  );
                },
                colors: [const Color(0xFF10B981), const Color(0xFF059669)],
              )
            else if (!isLocked)
              _buildActionButton(
                label: "Start Practice",
                icon: LucideIcons.arrow_right,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PracticeSessionScreen(
                        initialChord: level.chords.first,
                      ),
                    ),
                  );
                },
                colors: [const Color(0xFF0EA5E9), const Color(0xFF8B5CF6)],
              )
            else
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.lock,
                        color: Color(0xFF475569),
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Unlock with ${level.requiredPoints} points",
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Interactive buttons inside level cards helper
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required List<Color> colors,
  }) {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(colors: colors),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
