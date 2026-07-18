import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class BadgeItem {
  final String title;
  final String description;
  final int points;
  final IconData icon;
  final bool isUnlocked;
  final String? unlockedDate;

  BadgeItem({
    required this.title,
    required this.description,
    required this.points,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedDate,
  });
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded to perfectly replicate the layout data in the screenshot
    final List<BadgeItem> badges = [
      BadgeItem(
        title: "First Steps",
        description: "Complete your first chord",
        points: 50,
        icon: LucideIcons.guitar, // Tailor this to your asset/icon preference
        isUnlocked: true,
        unlockedDate: "Mar 10, 2026",
      ),
      BadgeItem(
        title: "Week Warrior",
        description: "Practice for 7 consecutive days",
        points: 150,
        icon: LucideIcons.flame,
        isUnlocked: true,
        unlockedDate: "Mar 15, 2026",
      ),
      BadgeItem(
        title: "Perfect Pitch",
        description: "Achieve 100% accuracy 5 times",
        points: 200,
        icon: LucideIcons.star,
        isUnlocked: true,
        unlockedDate: "Mar 18, 2026",
      ),
      BadgeItem(
        title: "Chord Master",
        description: "Master 50 different chords",
        points: 500,
        icon: LucideIcons.lock,
        isUnlocked: false,
      ),
      BadgeItem(
        title: "Practice Legend",
        description: "Complete 100 practice sessions",
        points: 750,
        icon: LucideIcons.lock,
        isUnlocked: false,
      ),
      BadgeItem(
        title: "Speed Demon",
        description: "Play 10 chords in under 2 minutes",
        points: 1000,
        icon: LucideIcons.lock,
        isUnlocked: false,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D121F), // Deep slate dark blue
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D121F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrow_left,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Achievements",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMetricsOverview(),
          const Divider(color: Color(0xFF1E293B), height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                return _buildBadgeCard(badges[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricColumn(
            "Unlocked",
            "3/6",
            const LinearGradient(
              colors: [Color(0xFF22D3EE), Color(0xFFA855F7)],
            ),
          ),
          _buildMetricColumn(
            "Total Points",
            "400",
            const LinearGradient(colors: [Colors.white, Colors.white]),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Gradient gradient) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 8),
        // ShaderMask applies the gradient directly to the text characters
        ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors
                  .white, // This base color acts as the canvas for the gradient
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(BadgeItem badge) {
    // Purple neon style if unlocked, muted layout style if locked
    final Color borderColor = badge.isUnlocked
        ? const Color(0xFF5B21B6).withOpacity(0.6)
        : const Color(0xFF1E293B);
    final Color backgroundColor = badge.isUnlocked
        ? const Color(0xFF121026).withOpacity(0.5)
        : const Color(0xFF0F1424);
    final double opacity = badge.isUnlocked ? 1.0 : 0.3;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: badge.isUnlocked
            ? [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Badge Icon Square
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: badge.isUnlocked
                  ? const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF4C1D95)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: badge.isUnlocked ? null : const Color(0xFF151B2C),
              border: Border.all(
                color: badge.isUnlocked
                    ? const Color(0xFF3B82F6).withOpacity(0.3)
                    : const Color(0xFF1E293B),
              ),
            ),
            child: Opacity(
              opacity: opacity,
              child: Icon(
                badge.isUnlocked ? badge.icon : LucideIcons.lock,
                color: badge.isUnlocked
                    ? _getIconColor(badge.title)
                    : const Color(0xFF475569),
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Badge Information Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.title,
                  style: TextStyle(
                    color: badge.isUnlocked
                        ? Colors.white
                        : const Color(0xFF475569),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badge.description,
                  style: TextStyle(
                    color: badge.isUnlocked
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF334155),
                    fontSize: 13,
                  ),
                ),
                if (badge.isUnlocked && badge.unlockedDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Unlocked on ${badge.unlockedDate}",
                    style: const TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Points Bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: badge.isUnlocked
                  ? const Color(0xFF2E1065)
                  : const Color(0xFF151B2C),
              shape: BoxShape.circle,
              border: Border.all(
                color: badge.isUnlocked
                    ? const Color(0xFF6B21A8).withOpacity(0.4)
                    : const Color(0xFF1E293B),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${badge.points}",
                  style: TextStyle(
                    color: badge.isUnlocked
                        ? const Color(0xFFA855F7)
                        : const Color(0xFF475569),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "pts",
                  style: TextStyle(
                    color: badge.isUnlocked
                        ? const Color(0xFFA855F7)
                        : const Color(0xFF475569),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Matches the colors used in the specific screenshot badges
  Color _getIconColor(String title) {
    if (title.contains("First Steps"))
      return const Color(0xFFF43F5E); // Pink guitar vibe
    if (title.contains("Warrior"))
      return const Color(0xFFFB923C); // Orange flame
    if (title.contains("Pitch")) return const Color(0xFFFBBF24); // Yellow star
    return Colors.white;
  }
}
