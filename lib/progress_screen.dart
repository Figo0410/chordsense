import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

// Data models for clean structure
class CompletedChord {
  final String name;
  final String date;
  final int accuracy;

  CompletedChord({
    required this.name,
    required this.date,
    required this.accuracy,
  });
}

class LearningChord {
  final String name;
  final int attempts;
  final int progress; // Percentage (e.g. 58)

  LearningChord({
    required this.name,
    required this.attempts,
    required this.progress,
  });
}

class PracticeSession {
  final String day;
  final String date;
  final String duration;
  final int accuracy;
  final int chordsCount;

  PracticeSession({
    required this.day,
    required this.date,
    required this.duration,
    required this.accuracy,
    required this.chordsCount,
  });
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data based on your exact UI image
    final List<CompletedChord> completedChords = [
      CompletedChord(
        name: "C Major",
        date: "Completed on Mar 14, 2026",
        accuracy: 94,
      ),
      CompletedChord(
        name: "G Major",
        date: "Completed on Mar 16, 2026",
        accuracy: 92,
      ),
      CompletedChord(
        name: "D Major",
        date: "Completed on Mar 17, 2026",
        accuracy: 89,
      ),
      CompletedChord(
        name: "E Minor",
        date: "Completed on Mar 18, 2026",
        accuracy: 91,
      ),
      CompletedChord(
        name: "A Minor",
        date: "Completed on Mar 19, 2026",
        accuracy: 88,
      ),
    ];

    final List<LearningChord> learningChords = [
      LearningChord(name: "F Major", attempts: 8, progress: 58),
      LearningChord(name: "B Minor", attempts: 12, progress: 62),
      LearningChord(name: "D7", attempts: 4, progress: 67),
    ];

    final List<PracticeSession> practiceSessions = [
      PracticeSession(
        day: "Monday",
        date: "Mar 18",
        duration: "25 min",
        accuracy: 78,
        chordsCount: 5,
      ),
      PracticeSession(
        day: "Tuesday",
        date: "Mar 19",
        duration: "30 min",
        accuracy: 82,
        chordsCount: 6,
      ),
      PracticeSession(
        day: "Wednesday",
        date: "Mar 20",
        duration: "20 min",
        accuracy: 75,
        chordsCount: 4,
      ),
      PracticeSession(
        day: "Thursday",
        date: "Mar 21",
        duration: "35 min",
        accuracy: 88,
        chordsCount: 7,
      ),
      PracticeSession(
        day: "Friday",
        date: "Mar 22",
        duration: "40 min",
        accuracy: 91,
        chordsCount: 8,
      ),
      PracticeSession(
        day: "Saturday",
        date: "Mar 23",
        duration: "45 min",
        accuracy: 94,
        chordsCount: 9,
      ),
      PracticeSession(
        day: "Sunday",
        date: "Mar 24",
        duration: "30 min",
        accuracy: 87,
        chordsCount: 6,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF030712), // Dark background
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Progress",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Track your learning journey",
              style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: OVERALL STATISTICS ---
            _buildSectionHeader("Overall Statistics"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          "47",
                          "Total Sessions",
                          LucideIcons.calendar,
                          const Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatTile(
                          "Level 7",
                          "Current Level",
                          LucideIcons.trending_up,
                          const Color(0xFFA855F7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          "3450",
                          "Total Points",
                          LucideIcons.gem,
                          const Color(0xFFF43F5E),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatTile(
                          "87%",
                          "Avg. Accuracy",
                          LucideIcons.award,
                          const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeStreakTile(
                          "Practice Time",
                          "18.5 hours",
                          null,
                          const Color(0xFF0EA5E9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeStreakTile(
                          "Best Streak",
                          "12 days",
                          "🔥",
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- SECTION 2: COMPLETED CHORDS ---
            Row(
              children: [
                const Icon(
                  LucideIcons.circle_check,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
                const SizedBox(width: 8),
                _buildSectionHeader(
                  "Completed Chords (${completedChords.length})",
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: completedChords.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final chord = completedChords[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF051D14).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            LucideIcons.music,
                            color: Color(0xFF10B981),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chord.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                chord.date,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${chord.accuracy}%",
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "accuracy",
                              style: TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // --- SECTION 3: CURRENTLY LEARNING ---
            Row(
              children: [
                const Icon(
                  LucideIcons.compass,
                  color: Color(0xFFF59E0B),
                  size: 16,
                ),
                const SizedBox(width: 8),
                _buildSectionHeader(
                  "Currently Learning (${learningChords.length})",
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: learningChords.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final chord = learningChords[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1304).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chord.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${chord.attempts} practice attempts",
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "${chord.progress}%",
                              style: const TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: chord.progress / 100,
                                    child: Container(
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Progress to Mastery",
                              style: TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 9,
                              ),
                            ),
                            Text(
                              "80% Req.",
                              style: TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // --- SECTION 4: RECENT PRACTICE SESSIONS ---
            _buildSectionHeader("Recent Practice Sessions"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: practiceSessions.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Color(0xFF1E293B), height: 20),
                itemBuilder: (context, index) {
                  final session = practiceSessions[index];
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.day,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              session.date,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildSessionStatCol("${session.duration}", "duration"),
                      const SizedBox(width: 20),
                      _buildSessionStatCol(
                        "${session.accuracy}%",
                        "accuracy",
                        valueColor: const Color(0xFF22D3EE),
                      ),
                      const SizedBox(width: 20),
                      _buildSessionStatCol("${session.chordsCount}", "chords"),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Section title builder
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Grid statistic tile helper
  Widget _buildStatTile(
    String value,
    String label,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 16),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bottom stats row tile helper
  Widget _buildTimeStreakTile(
    String label,
    String value,
    String? emoji,
    Color valueColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (emoji != null) ...[
                const SizedBox(width: 4),
                Text(emoji, style: const TextStyle(fontSize: 13)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Column helper inside the practice history list
  Widget _buildSessionStatCol(
    String value,
    String label, {
    Color valueColor = Colors.white,
  }) {
    return SizedBox(
      width: 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF475569), fontSize: 9),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
