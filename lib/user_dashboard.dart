import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'tuner_screen.dart'; // ImportTunerScreen widget
import 'learning_path_screen.dart'; // Import learning path screen
import 'practice_session_screen.dart'; // Import PracticeSessionScreen widget
import 'progress_screen.dart'; // Import ProgressScreen widget
import 'ranking_screen.dart'; // Import RankingScreen widget

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  //Mock data for the user dashboard.
  final String userName = 'Joshua';
  final int currentLevel = 7;
  final int totalPoints = 3450;
  final double progressPercent = 0.65; // 65% progress bar
  final int nextLevelPoints = 4000;
  final String currentChord = 'A Minor';

  int _currentIndex = 0; // Tracks bottom nav state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712), // Deep slate-950 base
      body: Stack(
        children: [
          // This automatically switches the body content based on selected tab!
          _buildBodyContent(),

          // --- FIXED CUSTOM BOTTOM NAV BAR ---
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  // Helper method to decide what to display on the screen
  Widget _buildBodyContent() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeDashboard(); // Your current home dashboard content
      case 1:
        return const LearningPathScreen(); // Your learning path screen
      case 2:
        return const TunerScreen();
      case 3:
        return const RankingScreen(); // Your ranking screen
      case 4:
        return _buildPlaceholderScreen("Profile Screen", LucideIcons.user);
      default:
        return _buildHomeDashboard();
    }
  }

  // A clean placeholder screen to display when on other tabs
  Widget _buildPlaceholderScreen(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: const Color(0xFF64748B)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Under Construction 🛠️",
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Requires the user to complete the guitar tuner setup before starting practice.
  void _showTuningModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Keeps the underlying container rounded
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.85, // Height matching the design
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Dark slate blue background
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFF97316),
              width: 1.5,
            ), // Distinct orange border
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Small drag handle at the top
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF475569),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // --- 1. NEW LEARNER BADGE ---
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316), // Orange
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                LucideIcons.guitar,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "New Learner",
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
                      const SizedBox(height: 12),

                      // --- 2. FLOATING GLOW MUSIC ICON ---
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF97316).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.music,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // --- 3. WELCOME TITLE ---
                      const Text(
                        "Welcome to ChordSense!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text("🎸", style: TextStyle(fontSize: 22)),
                      const SizedBox(height: 20),

                      // --- 4. EXPLANATION CONTAINER ---
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF2D1B18,
                          ), // Deep warm brown tint
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFEA580C).withOpacity(0.4),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  LucideIcons.info,
                                  color: Color(0xFFF97316),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        color: Color(0xFFCBD5E1),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Before you start learning:\n",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(text: "Proper tuning is "),
                                        TextSpan(
                                          text: "essential",
                                          style: TextStyle(
                                            color: Color(0xFFF97316),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              " for accurate chord detection and successful learning. Please complete the guitar tuner setup first.",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // --- PROGRESS STEPS ---
                            // Step 1: Active Complete Tuner
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFF97316),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "1",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Complete Tuner Setup",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 11),
                              child: SizedBox(
                                height: 12,
                                child: VerticalDivider(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                              ),
                            ),
                            // Step 2: Locked Practice
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF334155),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "2",
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Start Practice Sessions",
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  LucideIcons.lock,
                                  color: Color(0xFF64748B),
                                  size: 14,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- 5. RED/ORANGE GRADIENT BUTTON ---
                      Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFEA580C),
                              Color(0xFFDC2626),
                            ], // Deep Orange to Red
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEA580C).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // 1. First, this closes the warning modal sheet
                              Navigator.pop(context);

                              // 2. Second, this immediately opens your practice screen!
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PracticeSessionScreen(),
                                ),
                              );
                            },
                            child: Container(
                              // ... leave everything else in your container exactly as it is ...
                              child: Center(
                                child: const Text(
                                  "Complete Tuner Setup",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // --- 6. FOOTER TEXT ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            LucideIcons.lock,
                            color: Color(0xFF475569),
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Practice will be available after tuning",
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Move your scrollable dashboard content here
  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120), // Prevent nav bar overlaps
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER AREA ---
          Container(
            padding: const EdgeInsets.fromLTRB(24, 55, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B132B), Color(0xFF030712)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back, $userName!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Ready to practice today?",
                          style: TextStyle(
                            color: Color(0xFF64748B), // Slate-500
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    // Glowing Music Badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.music,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- LEVEL & POINTS CARD ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF0F172A,
                    ).withOpacity(0.4), // Slate-900/40
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1E293B),
                    ), // Slate-800
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Current Level",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFF22D3EE),
                                        Color(0xFFA855F7),
                                      ],
                                    ).createShader(bounds),
                                child: Text(
                                  "Level $currentLevel",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Total Points",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "3450",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${nextLevelPoints - totalPoints} to next level",
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          minHeight: 6,
                          backgroundColor: const Color(0xFF1E293B),
                          color: const Color(
                            0xFF6366F1,
                          ), // Beautiful Indigo/Violet progress color
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- MAIN VIEWPORT BODY ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. STATS ROW
                Row(
                  children: [
                    _buildStatCard(
                      "Accuracy",
                      "87%",
                      LucideIcons.target,
                      const Color(0xFF22D3EE),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      "Streak",
                      "12 days",
                      LucideIcons.zap,
                      const Color(0xFFA855F7),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      "Chords Mastered",
                      "23",
                      LucideIcons.music,
                      const Color(0xFFEC4899),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. QUICK ACTIONS SECTION
                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Start Practice Gradient Button
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF06B6D4),
                        Color(0xFF9333EA),
                      ], // Cyan to purple
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showTuningModal(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.play,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Start Practice",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "Continue learning chords",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Triple Action Rows (Progress, Ranking, Badges)
                Row(
                  children: [
                    _buildMiniActionButton(
                      "Progress",
                      LucideIcons.trending_up,
                      const Color(0xFF06B6D4),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProgressScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildMiniActionButton(
                      "Ranking",
                      LucideIcons.trophy,
                      const Color(0xFFEAB308),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RankingScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildMiniActionButton(
                      "Badges",
                      LucideIcons.award,
                      const Color(0xFFA855F7),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Wide Action Rows
                _buildWideActionRow(
                  "Learning Path",
                  "View all levels & chords",
                  LucideIcons.map,
                  const Color(0xFFEC4899),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LearningPathScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildWideActionRow(
                  "Song Library",
                  "Learn Filipino songs",
                  LucideIcons.music,
                  const Color(0xFFEAB308),
                ),
                const SizedBox(height: 28),

                // 3. CURRENTLY LEARNING SECTION
                const Text(
                  "Currently Learning",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF9333EA).withOpacity(0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9333EA).withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Next Chord",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFF22D3EE),
                                        Color(0xFFA855F7),
                                      ],
                                    ).createShader(bounds),
                                child: Text(
                                  currentChord,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF9333EA).withOpacity(0.5),
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.music,
                              color: Color(0xFFA855F7),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Pink/Purple Gradient Continue Button
                      Container(
                        height: 44,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _showTuningModal(context),
                            child: const Center(
                              child: Text(
                                "Continue Learning",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 4. NEXT MILESTONE SECTION
                const Text(
                  "Next Milestone",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF020617),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Reach Level 8",
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "550 points needed",
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "86%",
                            style: TextStyle(
                              color: Color(0xFF22D3EE),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.86,
                          minHeight: 6,
                          backgroundColor: Color(0xFF0F172A),
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- STAT CARD WIDGET CREATOR ---
  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 20),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MINI ACTIONS WIDGET CREATOR ---
  // --- MINI ACTION BUTTON WIDGET CREATOR ---
  Widget _buildMiniActionButton(
    String label,
    IconData icon,
    Color iconColor, {
    VoidCallback? onTap, // 👈 Added this optional parameter
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap, // 👈 Hooked up the tap event here!
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDE ACTION LIST ROW WIDGET CREATOR ---

  Widget _buildWideActionRow(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor, {
    VoidCallback? onTap, // 👈 Added this optional onTap parameter
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap, // 👈 Triggers your custom navigation!
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevron_right,
                  color: Color(0xFF475569),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- CUSTOM COMPACT BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Color(0xFF090D1F), // Dark midnight nav background
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, "Home", Icons.home),
          _buildNavItem(1, "Practice", Icons.play_arrow),
          _buildNavItem(2, "Tuner", Icons.tune),
          _buildNavItem(3, "Ranking", Icons.star),
          _buildNavItem(4, "Profile", Icons.person),
        ],
      ),
    );
  }

  // --- NAV ITEM BUILDER ---
  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? const Color(0xFF22D3EE)
        : const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: () {
          // 1. Intercept if the user clicks "Practice" (index 1)
          if (index == 1) {
            _showTuningModal(context); // Pop open the warning sheet!
            return; // Stop execution here so the background screen doesn't shift
          }

          // 2. For all other tabs, update the index normally
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
            const SizedBox(height: 4),
            // Floating dot decoration for selected item
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF22D3EE)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
