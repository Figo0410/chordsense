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

  //Add this constructor
  factory CompletedChord.fromMap(Map<String, dynamic> map) {
    return CompletedChord(
      name: map['name'] ?? '',
      date: map['date'] ?? '',
      accuracy:
          (map['accuracy'] as num?)?.toInt() ?? 0, // Ensure accuracy is an int
    );
  }
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

  // 👈 Add this constructor
  factory LearningChord.fromMap(Map<String, dynamic> map) {
    return LearningChord(
      name: map['name'] ?? '',
      attempts: map['attempts'] ?? 0,
      progress: (map['progress'] as num?)?.toInt() ?? 0,
    );
  }
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

  // 👈 Add this constructor
  factory PracticeSession.fromMap(Map<String, dynamic> map) {
    return PracticeSession(
      day: map['day'] ?? '',
      date: map['date'] ?? '',
      duration: map['duration'] ?? '',
      accuracy: (map['accuracy'] as num?)?.toInt() ?? 0,
      chordsCount: (map['chordsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProgressScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProgressScreen({super.key, required this.userData});
  @override
  Widget build(BuildContext context) {
    // Safely extract arrays from your MongoDB document
    final List<CompletedChord> completedChords =
        (userData['completedChords'] as List<dynamic>?)
            ?.map(
              (item) => CompletedChord.fromMap(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList() ??
        [];

    final List<LearningChord> learningChords =
        (userData['learningChords'] as List<dynamic>?)
            ?.map(
              (item) =>
                  LearningChord.fromMap(Map<String, dynamic>.from(item as Map)),
            )
            .toList() ??
        [];

    final List<PracticeSession> practiceSessions =
        (userData['practiceSessions'] as List<dynamic>?)
            ?.map(
              (item) => PracticeSession.fromMap(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList() ??
        [];

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
                          "${userData['chordsMastered'] ?? 0}", // Maps to chordsMastered in User.js
                          "Mastered Chords",
                          LucideIcons.award,
                          const Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatTile(
                          "Level ${userData['currentLevel'] ?? 1}", // Maps to currentLevel
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
                          "${userData['totalPoints'] ?? 0}", // Maps to totalPoints
                          "Total Points",
                          LucideIcons.gem,
                          const Color(0xFFF43F5E),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatTile(
                          "${userData['accuracy'] ?? 0}%", // Maps to accuracy
                          "Avg. Accuracy",
                          LucideIcons.circle_check,
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
                          "Current Chord",
                          "${userData['currentChord'] ?? 'C Major'}", // Maps to currentChord
                          null,
                          const Color(0xFF0EA5E9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeStreakTile(
                          "Streak",
                          "${userData['streak'] ?? 0} days", // Maps to streak
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
