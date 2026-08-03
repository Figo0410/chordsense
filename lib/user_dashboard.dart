import 'package:chordsense/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'tuner_screen.dart'; // Import TunerScreen widget
import 'learning_path_screen.dart'; // Import learning path screen
import 'practice_session_screen.dart'; // Import PracticeSessionScreen widget
import 'progress_screen.dart'; // Import ProgressScreen widget
import 'ranking_screen.dart'; // Import RankingScreen widget
import 'achievements_screen.dart'; // Import AchievementsScreen widget
import 'song_library_screen.dart'; // Import SongLibraryScreen widget

class UserDashboard extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const UserDashboard({super.key, this.userData});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0; // Tracks bottom nav state

  // 1. Declare class-level fields (Accessible anywhere in this class)
  String userName = 'User';
  int currentLevel = 1;
  int totalPoints = 0;
  double progressPercent = 0.0;
  int nextLevelPoints = 1000;
  String currentChord = 'C Major';

  int accuracy = 0;
  int streak = 0;
  int chordsMastered = 0;

  bool hasCompletedTuner = false; // REAL DATA GUARD FOR TUNER REQUIREMENT

  Map<String, dynamic> userProfileData = {};

  // Helper method to safely extract raw String ID whether it's String or Map ({$oid: "..."})
  String? _getUserId() {
    if (userProfileData.containsKey('_id')) {
      final idVal = userProfileData['_id'];
      if (idVal is String) return idVal;
      if (idVal is Map && idVal.containsKey('\$oid')) {
        return idVal['\$oid'].toString();
      }
      return idVal.toString();
    }
    if (userProfileData.containsKey('id')) {
      return userProfileData['id']?.toString();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _loadUserData(widget.userData!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 2. Extract MongoDB data passed from LoginScreen or Main route settings
    final Map<String, dynamic>? routeUserData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (routeUserData != null) {
      _loadUserData(routeUserData);
    }
  }

  void _loadUserData(Map<String, dynamic> userData) {
    setState(() {
      userProfileData = userData;

      userName = userData['username'] ?? 'User';
      currentLevel = (userData['currentLevel'] as num?)?.toInt() ?? 1;
      totalPoints = (userData['totalPoints'] as num?)?.toInt() ?? 0;
      nextLevelPoints = (userData['nextLevelPoints'] as num?)?.toInt() ?? 1000;
      currentChord = userData['currentChord'] ?? 'C Major';

      accuracy = (userData['accuracy'] as num?)?.toInt() ?? 0;
      streak = (userData['streak'] as num?)?.toInt() ?? 0;
      chordsMastered = (userData['chordsMastered'] as num?)?.toInt() ?? 0;

      // Extract real tuner completion status (defaults to false only if missing)
      hasCompletedTuner = userData['hasCompletedTuner'] == true;

      // DYNAMIC CALCULATION:
      if (nextLevelPoints > 0) {
        progressPercent = (totalPoints / nextLevelPoints) * 100;
        progressPercent = progressPercent.clamp(0.0, 100.0);
      } else {
        progressPercent = 0.0;
      }
    });
  }

  // Helper method to check if user can proceed to practice or must see the tuning modal
  void _handlePracticeAccess() {
    if (hasCompletedTuner) {
      setState(() {
        _currentIndex = 1; // Direct to Practice tab
      });
    } else {
      _showTuningModal(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712), // Deep slate-950 base
      body: Stack(
        children: [
          // 3. Call _buildBodyContent() WITHOUT passing arguments
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
        return _buildHomeDashboard();
      case 1:
        return PracticeSessionScreen(
          onGoBack: () {
            setState(() {
              _currentIndex = 0; // Switch back to Home tab
            });
          },
        );
      case 2:
        return TunerScreen(
          userId: _getUserId(),
          onTuningComplete: () {
            setState(() {
              hasCompletedTuner = true;
              userProfileData['hasCompletedTuner'] = true;
              _currentIndex = 1; // Direct to practice tab upon completing tuner
            });
          },
        );
      case 3:
        return RankingScreen(
          userId: _getUserId(),
          username: userProfileData['username']?.toString(),
          onGoToHome: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      case 4:
        return ProfileScreen(userProfileData: userProfileData);
      default:
        return _buildHomeDashboard();
    }
  }

  // Requires the user to complete the guitar tuner setup before starting practice.
  void _showTuningModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFF97316), width: 1.5),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
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
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316),
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
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D1B18),
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
                      Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEA580C), Color(0xFFDC2626)],
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
                              Navigator.pop(context);
                              // Redirect user directly to the Tuner Screen tab to finish tuning
                              setState(() {
                                _currentIndex = 2;
                              });
                            },
                            child: const Center(
                              child: Text(
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
                      const SizedBox(height: 14),
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

  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B)),
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
                              Text(
                                "$totalPoints",
                                style: const TextStyle(
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressPercent / 100,
                          minHeight: 6,
                          backgroundColor: const Color(0xFF1E293B),
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatCard(
                      "Accuracy",
                      "$accuracy%",
                      LucideIcons.target,
                      const Color(0xFF22D3EE),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      "Streak",
                      "$streak",
                      LucideIcons.zap,
                      const Color(0xFFA855F7),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      "Chords Mastered",
                      "$chordsMastered",
                      LucideIcons.music,
                      const Color(0xFFEC4899),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF9333EA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _handlePracticeAccess,
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
                            builder: (context) =>
                                ProgressScreen(userData: userProfileData),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildMiniActionButton(
                      "Ranking",
                      LucideIcons.trophy,
                      const Color(0xFFEAB308),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RankingScreen(),
                            settings: RouteSettings(
                              arguments: {
                                'userId': _getUserId(),
                                'username': userProfileData['username'],
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildMiniActionButton(
                      "Badges",
                      LucideIcons.award,
                      const Color(0xFFA855F7),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AchievementsScreen(
                              userProfileData: userProfileData,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildWideActionRow(
                  "Learning Path",
                  "View all levels & chords",
                  LucideIcons.map,
                  const Color(0xFFEC4899),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LearningPathScreen(
                          userId: _getUserId(),
                          initialPoints: totalPoints,
                          initialCurrentLevel: currentLevel,
                          initialCompletedLevels:
                              userProfileData['completedLevels']
                                  as List<dynamic>?,
                        ),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SongLibraryScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
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
                            onTap: _handlePracticeAccess,
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
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Reach Level ${currentLevel + 1}",
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${nextLevelPoints - totalPoints} points needed",
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${progressPercent.toInt()}%",
                            style: const TextStyle(
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
                        child: LinearProgressIndicator(
                          value: progressPercent / 100,
                          minHeight: 6,
                          backgroundColor: const Color(0xFF0F172A),
                          color: const Color(0xFF1E293B),
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

  Widget _buildMiniActionButton(
    String label,
    IconData icon,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideActionRow(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor, {
    VoidCallback? onTap,
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
          onTap: onTap,
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

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Color(0xFF090D1F),
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, "Home", Icons.home),
          _buildNavItem(
            1,
            "Practice",
            Icons.play_arrow_rounded,
          ), // Practice Tab
          _buildNavItem(2, "Tuner", Icons.tune),
          _buildNavItem(3, "Ranking", Icons.star),
          _buildNavItem(4, "Profile", Icons.person),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? const Color(0xFF22D3EE)
        : const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: () {
          // If user taps the Practice tab (index 1), run the tuner completion check first
          if (index == 1) {
            _handlePracticeAccess();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
            const SizedBox(height: 4),
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
