import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'achievements_screen.dart'; // Import to link the "View All" button
import 'login_screen.dart'; // Import to navigate to the login screen

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildUserCard(),
              const SizedBox(height: 16),
              _buildStatsRow(),
              const SizedBox(height: 16),
              _buildRecentAchievementsCard(context),
              const SizedBox(height: 16),
              _buildMenuOption(
                icon: LucideIcons.settings,
                label: "Settings",
                onTap: () {},
              ),
              _buildMenuOption(
                icon: LucideIcons.bell,
                label: "Notifications",
                onTap: () {},
              ),
              _buildMenuOption(
                icon: LucideIcons.share_2,
                label: "Share App",
                onTap: () {},
              ),
              _buildMenuOption(
                icon: LucideIcons.circle_question_mark,
                label: "Help & Support",
                onTap: () {},
              ),
              _buildMenuOption(
                icon: LucideIcons.log_out,
                label: "Logout",
                isLogout: true,
                onTap: () {
                  // Trigger logout logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildFooter(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2),
        Text(
          "Manage your account settings",
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFFA855F7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA855F7).withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.user,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              // Name, Email, and Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Joshua",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "joshua@example.com",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Level Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E1065).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF6B21A8).withOpacity(0.5),
                            ),
                          ),
                          child: const Text(
                            "Level 7",
                            style: TextStyle(
                              color: Color(0xFFA855F7),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Points Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF082F49).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF0EA5E9).withOpacity(0.5),
                            ),
                          ),
                          child: const Text(
                            "3,450 pts",
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1E293B)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Edit Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "23",
            "Chords Mastered",
            const Color(0xFF22D3EE),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard("47", "Sessions", const Color(0xFFA855F7)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard("12 🔥", "Day Streak", const Color(0xFFF43F5E)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievementsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Achievements",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AchievementsScreen(),
                    ),
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAchievementItem(
                  LucideIcons.guitar,
                  const Color(0xFFF43F5E),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAchievementItem(
                  LucideIcons.flame,
                  const Color(0xFFFB923C),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAchievementItem(
                  LucideIcons.star,
                  const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E1065).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          const Text(
            "Achievement",
            style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final Color textColor = isLogout ? const Color(0xFFEF4444) : Colors.white;
    final Color iconColor = isLogout
        ? const Color(0xFFEF4444)
        : const Color(0xFF94A3B8);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isLogout
                    ? const Color(0xFFEF4444).withOpacity(0.2)
                    : const Color(0xFF1E293B),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 16),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: const [
          Text(
            "ChordSense v1.0.0",
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "© 2026 ChordSense. All rights reserved.",
            style: TextStyle(color: Color(0xFF334155), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
