import 'dart:convert'; // 👈 FIXES: jsonDecode error
import 'package:http/http.dart' as http; // Needed for http.get
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'services/api_service.dart';

class BadgeItem {
  final String id;
  final String title;
  final String description;
  final int points;
  final IconData icon;
  final bool isUnlocked;
  final String? unlockedDate;

  BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedDate,
  });
}

class AchievementsScreen extends StatefulWidget {
  final Map<String, dynamic>? userProfileData;

  const AchievementsScreen({super.key, this.userProfileData});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    if (widget.userProfileData != null) {
      userData = widget.userProfileData!;
    }
    _fetchFreshUserData(); // 👈 Trigger backend check when screen loads
  }

  Future<void> _fetchFreshUserData() async {
    final userId = userData['_id'] ?? userData['id'];
    debugPrint('🔍 [FLUTTER] Fetching fresh data for userId: $userId');

    if (userId == null) {
      debugPrint('❌ [FLUTTER] Error: userId is null!');
      return;
    }

    try {
      // 👈 ADD /auth HERE TO MATCH server.js
      final url = Uri.parse('${ApiService.baseUrl}/auth/profile/$userId');
      debugPrint('📡 [FLUTTER] Sending GET request to: $url');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📩 [FLUTTER] Response Status Code: ${response.statusCode}');
      debugPrint('📩 [FLUTTER] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final updatedUser = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            userData = updatedUser;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ [FLUTTER] Network Exception: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fallback to route arguments if userProfileData wasn't passed directly via constructor
    if (userData.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        setState(() {
          userData = args;
        });
      }
    }
  }

  List<BadgeItem> _generateBadges() {
    final int chordsMastered =
        (userData['chordsMastered'] as num?)?.toInt() ?? 0;
    final int streak = (userData['streak'] as num?)?.toInt() ?? 0;
    final int accuracy = (userData['accuracy'] as num?)?.toInt() ?? 0;
    final int sessionsCompleted =
        (userData['sessionsCompleted'] as num?)?.toInt() ?? 0;

    // Optional list of unlocked badges from DB if stored directly as array: e.g. userData['unlockedBadges']
    final List<dynamic> unlockedBadgeIds = userData['unlockedBadges'] is List
        ? userData['unlockedBadges']
        : [];

    return [
      BadgeItem(
        id: "first_steps",
        title: "First Steps",
        description: "Complete your first chord",
        points: 50,
        icon: LucideIcons.guitar,
        isUnlocked:
            unlockedBadgeIds.contains("first_steps") ||
            chordsMastered >= 1 ||
            sessionsCompleted >= 1,
        unlockedDate: userData['firstChordDate']?.toString() ?? "Completed",
      ),
      BadgeItem(
        id: "week_warrior",
        title: "Week Warrior",
        description: "Practice for 7 consecutive days",
        points: 150,
        icon: LucideIcons.flame,
        isUnlocked: unlockedBadgeIds.contains("week_warrior") || streak >= 7,
        unlockedDate: userData['streakDate']?.toString() ?? "Completed",
      ),
      BadgeItem(
        id: "perfect_pitch",
        title: "Perfect Pitch",
        description: "Achieve 100% accuracy 5 times",
        points: 200,
        icon: LucideIcons.star,
        isUnlocked:
            unlockedBadgeIds.contains("perfect_pitch") || accuracy >= 100,
        unlockedDate: userData['perfectPitchDate']?.toString() ?? "Completed",
      ),
      BadgeItem(
        id: "chord_master",
        title: "Chord Master",
        description: "Master 50 different chords",
        points: 500,
        icon: LucideIcons.lock,
        isUnlocked:
            unlockedBadgeIds.contains("chord_master") || chordsMastered >= 50,
        unlockedDate: userData['chordMasterDate']?.toString(),
      ),
      BadgeItem(
        id: "practice_legend",
        title: "Practice Legend",
        description: "Complete 100 practice sessions",
        points: 750,
        icon: LucideIcons.lock,
        isUnlocked:
            unlockedBadgeIds.contains("practice_legend") ||
            sessionsCompleted >= 100,
        unlockedDate: userData['practiceLegendDate']?.toString(),
      ),
      BadgeItem(
        id: "speed_demon",
        title: "Speed Demon",
        description: "Play 10 chords in under 2 minutes",
        points: 1000,
        icon: LucideIcons.lock,
        isUnlocked: unlockedBadgeIds.contains("speed_demon"),
        unlockedDate: userData['speedDemonDate']?.toString(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<BadgeItem> badges = _generateBadges();

    // Dynamically calculate metrics
    final int unlockedCount = badges.where((b) => b.isUnlocked).length;
    final int totalEarnedPoints = badges
        .where((b) => b.isUnlocked)
        .fold(0, (sum, badge) => sum + badge.points);

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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
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
          _buildMetricsOverview(
            unlockedCount,
            badges.length,
            totalEarnedPoints,
          ),
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

  Widget _buildMetricsOverview(
    int unlockedCount,
    int totalBadges,
    int totalPoints,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricColumn(
            "Unlocked",
            "$unlockedCount/$totalBadges",
            const LinearGradient(
              colors: [Color(0xFF22D3EE), Color(0xFFA855F7)],
            ),
          ),
          _buildMetricColumn(
            "Total Points",
            "$totalPoints",
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
        ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
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

  Color _getIconColor(String title) {
    if (title.contains("First Steps")) return const Color(0xFFF43F5E);
    if (title.contains("Warrior")) return const Color(0xFFFB923C);
    if (title.contains("Pitch")) return const Color(0xFFFBBF24);
    return Colors.white;
  }
}
