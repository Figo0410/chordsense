import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class LeaderboardUser {
  final int rank;
  final String name;
  final int level;
  final int xp;
  final int days;
  final int accuracy;
  final int sessions;
  final bool isCurrentUser;
  final String avatarAsset; // In case you want to use asset images later

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.level,
    required this.xp,
    required this.days,
    required this.accuracy,
    required this.sessions,
    this.isCurrentUser = false,
    this.avatarAsset = "",
  });
}

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  int _selectedTab = 0; // 0: Top Accuracy, 1: Weekly, 2: Most Improved

  @override
  Widget build(BuildContext context) {
    // Exact list of users from your reference design
    final List<LeaderboardUser> users = [
      LeaderboardUser(
        rank: 1,
        name: "Maria Santos",
        level: 15,
        xp: 12500,
        days: 45,
        accuracy: 98,
        sessions: 234,
      ),
      LeaderboardUser(
        rank: 2,
        name: "Juan Cruz",
        level: 14,
        xp: 11200,
        days: 38,
        accuracy: 96,
        sessions: 198,
      ),
      LeaderboardUser(
        rank: 3,
        name: "Sofia Reyes",
        level: 13,
        xp: 10800,
        days: 32,
        accuracy: 95,
        sessions: 187,
      ),
      LeaderboardUser(
        rank: 4,
        name: "Carlos Luna",
        level: 12,
        xp: 9500,
        days: 28,
        accuracy: 93,
        sessions: 165,
      ),
      LeaderboardUser(
        rank: 5,
        name: "Ana Torres",
        level: 11,
        xp: 8900,
        days: 25,
        accuracy: 91,
        sessions: 152,
      ),
      LeaderboardUser(
        rank: 6,
        name: "Miguel Ramos",
        level: 11,
        xp: 8200,
        days: 22,
        accuracy: 90,
        sessions: 143,
      ),
      LeaderboardUser(
        rank: 7,
        name: "Joshua",
        level: 7,
        xp: 3450,
        days: 12,
        accuracy: 87,
        sessions: 78,
        isCurrentUser: true,
      ),
      LeaderboardUser(
        rank: 8,
        name: "Lisa Garcia",
        level: 9,
        xp: 6500,
        days: 15,
        accuracy: 85,
        sessions: 112,
      ),
    ];

    // Podium rankings (Top 1, 2, 3)
    final top1 = users.firstWhere((u) => u.rank == 1);
    final top2 = users.firstWhere((u) => u.rank == 2);
    final top3 = users.firstWhere((u) => u.rank == 3);

    return Scaffold(
      backgroundColor: const Color(0xFF030712), // Deep slate-950 base
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            _buildHeader(),

            // --- TAB SELECTOR ---
            _buildTabSelector(),

            // --- SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- PODIUM COMPONENT ---
                    const SizedBox(height: 16),
                    _buildPodium(top1, top2, top3),
                    const SizedBox(height: 24),

                    // --- ALL RANKINGS TITLE ---
                    Row(
                      children: const [
                        Icon(
                          LucideIcons.star,
                          color: Color(0xFF22D3EE),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "All Rankings",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // --- RANKINGS LIST ---
                    ...users
                        .map((user) => _buildLeaderboardTile(user))
                        .toList(),
                    const SizedBox(height: 24),

                    // --- YOUR PERFORMANCE SUMMARY ---
                    Row(
                      children: const [
                        Icon(
                          LucideIcons.trending_up,
                          color: Color(0xFFA855F7),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Your Performance Summary",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPerformanceSummary(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header design
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.trophy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Leaderboard",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Compete with fellow learners",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Custom pill tabs
  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem(0, "Top Accuracy")),
          Expanded(child: _buildTabItem(1, "Weekly")),
          Expanded(child: _buildTabItem(2, "Most Improved")),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFFA855F7)],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Top-3 Podium Layout
  Widget _buildPodium(
    LeaderboardUser top1,
    LeaderboardUser top2,
    LeaderboardUser top3,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Rank 2 (Left)
        _buildPodiumPosition(
          top2,
          "2",
          const Color(0xFF475569),
          const Color(0xFF334155),
          const Color(0xFF1E293B),
        ),

        // Rank 1 (Center - Elevated)
        _buildPodiumPosition(
          top1,
          "1",
          const Color(0xFFF59E0B),
          const Color(0xFFD97706),
          const Color(0xFF451A03),
          isFirst: true,
        ),

        // Rank 3 (Right)
        _buildPodiumPosition(
          top3,
          "3",
          const Color(0xFFB45309),
          const Color(0xFF78350F),
          const Color(0xFF2D1500),
        ),
      ],
    );
  }

  Widget _buildPodiumPosition(
    LeaderboardUser user,
    String rank,
    Color primaryColor,
    Color accentColor,
    Color cardBg, {
    bool isFirst = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar stack with crowns
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Circular Avatar Frame
            Container(
              width: isFirst ? 72 : 56,
              height: isFirst ? 72 : 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [primaryColor, accentColor]),
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF1E293B),
                  child: Text(
                    user.name.substring(0, 1),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isFirst ? 20 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Floating Crown on Top 1
            if (isFirst)
              const Positioned(
                top: -14,
                child: Icon(
                  LucideIcons.crown,
                  color: Color(0xFFF59E0B),
                  size: 18,
                ),
              ),
            // Floating Rank Bubble
            Positioned(
              top: isFirst ? 20 : 12,
              right: isFirst ? -12 : -10,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
                child: Text(
                  rank,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Name and level info
        Text(
          user.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Level ${user.level}",
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
        ),
        const SizedBox(height: 8),

        // Percentage Card below
        Container(
          width: isFirst ? 110 : 95,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text(
                "${user.accuracy}%",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: isFirst ? 15 : 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Accuracy",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Row Item for each Rank
  Widget _buildLeaderboardTile(LeaderboardUser user) {
    final bool isTop3 = user.rank <= 3;
    final Color borderAccent = user.isCurrentUser
        ? const Color(0xFF0EA5E9)
        : (isTop3
              ? const Color(0xFFD97706).withOpacity(0.4)
              : const Color(0xFF1E293B));

    final Color tileBackground = user.isCurrentUser
        ? const Color(0xFF0C4A6E).withOpacity(0.2)
        : (isTop3
              ? const Color(0xFF451A03).withOpacity(0.1)
              : const Color(0xFF0F172A).withOpacity(0.3));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: tileBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderAccent,
          width: user.isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Rank Text/Badge
              SizedBox(
                width: 30,
                child: isTop3
                    ? Icon(
                        LucideIcons.award,
                        color: user.rank == 1
                            ? const Color(0xFFF59E0B)
                            : (user.rank == 2
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFFB45309)),
                        size: 18,
                      )
                    : Text(
                        "#${user.rank}",
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              // Mini-Avatar
              CircleAvatar(
                radius: 12,
                backgroundColor: user.isCurrentUser
                    ? const Color(0xFF0284C7)
                    : const Color(0xFF1E293B),
                child: Text(
                  user.name.substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name and Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user.isCurrentUser) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0EA5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "You",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.sparkles,
                          color: Color(0xFFF59E0B),
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "Lv ${user.level}",
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.star,
                          color: Color(0xFFE2E8F0),
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "${user.xp} XP",
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.flame,
                          color: Color(0xFFF97316),
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "${user.days}d",
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Accuracy percentage on the right
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${user.accuracy}%",
                    style: TextStyle(
                      color: user.rank <= 3
                          ? const Color(0xFFF59E0B)
                          : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "Accuracy",
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 8,
                    ),
                  ),
                  Text(
                    "${user.sessions} sessions",
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 7,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Clean Visual Progress bar matching your aesthetic
          Stack(
            children: [
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: user.accuracy / 100,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: user.isCurrentUser
                          ? [const Color(0xFF0EA5E9), const Color(0xFF22D3EE)]
                          : [const Color(0xFF475569), const Color(0xFF94A3B8)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Your Performance Summary Card
  Widget _buildPerformanceSummary() {
    return Container(
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
                child: _buildSummaryGridTile(
                  "Current Rank",
                  "#7",
                  const Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryGridTile(
                  "Points to Next",
                  "280",
                  const Color(0xFFA855F7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryGridTile(
                  "Sessions This Week",
                  "18",
                  const Color(0xFFEC4899),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryGridTile(
                  "Avg. Accuracy",
                  "87%",
                  const Color(0xFFEAB308),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pink Banner Butto
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // 1. Show the tuning warning modal sheet first to verify their guitar is tuned!
              },
              borderRadius: BorderRadius.circular(8),
              child: Ink(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFD946EF)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(LucideIcons.trophy, color: Colors.white, size: 14),
                    SizedBox(width: 8),
                    Text(
                      "Keep Practicing to Climb",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGridTile(String label, String value, Color accentColor) {
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
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
