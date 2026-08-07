import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'services/api_service.dart';
import 'practice_session_screen.dart';

class LevelData {
  final int levelNumber;
  final String title;
  final String difficulty;
  final List<String> chords;
  final int requiredPoints;
  final int rewardPoints;
  final double? progress;
  final int? accuracy;

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
  final String? userId;
  final int? initialPoints;
  final int? initialCurrentLevel;
  final List<dynamic>? initialCompletedLevels;

  const LearningPathScreen({
    super.key,
    this.userId,
    this.initialPoints,
    this.initialCurrentLevel,
    this.initialCompletedLevels,
  });

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

  bool _isLoading = true;
  String? _errorMessage;
  List<LevelData> _levels = [];

  int _userTotalPoints = 0;
  int _userCurrentLevel = 1;
  List<dynamic> _userCompletedLevels = [];
  List<String> _userCompletedChords = [];

  @override
  void initState() {
    super.initState();
    _userTotalPoints = widget.initialPoints ?? 0;
    _userCurrentLevel = widget.initialCurrentLevel ?? 1;
    _userCompletedLevels = widget.initialCompletedLevels ?? [];
    _fetchLearningPathData();
  }

  List<Map<String, dynamic>> _getFallbackLevels() {
    return [
      {
        "levelNumber": 1,
        "title": "Basic Foundation",
        "difficulty": "Beginner",
        "chords": ["C Major", "G Major"],
        "requiredPoints": 0,
        "rewardPoints": 100,
      },
      {
        "levelNumber": 2,
        "title": "Major Chords",
        "difficulty": "Beginner",
        "chords": ["D Major", "A Major"],
        "requiredPoints": 100,
        "rewardPoints": 150,
      },
      {
        "levelNumber": 3,
        "title": "Minor Chords",
        "difficulty": "Beginner",
        "chords": ["A Minor", "E Minor", "D Minor"],
        "requiredPoints": 250,
        "rewardPoints": 200,
      },
      {
        "levelNumber": 4,
        "title": "Chord Transitions",
        "difficulty": "Intermediate",
        "chords": ["C-G-D Transition", "Am-Em Switch"],
        "requiredPoints": 450,
        "rewardPoints": 250,
      },
    ];
  }

  Future<void> _fetchLearningPathData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      int fetchedPoints = _userTotalPoints;
      int fetchedCurrentLevel = _userCurrentLevel;
      List<dynamic> fetchedCompletedLevels = _userCompletedLevels;
      List<String> fetchedCompletedChords = [];

      String searchUserId = widget.userId ?? "6a72a3418427dadc19d157d";

      if (searchUserId.isNotEmpty) {
        try {
          final responseData = await ApiService.getUserProfile(searchUserId);
          final userData =
              responseData['user'] ?? responseData['data'] ?? responseData;

          fetchedPoints =
              (userData['totalPoints'] as num?)?.toInt() ?? fetchedPoints;
          fetchedCurrentLevel =
              (userData['currentLevel'] as num?)?.toInt() ??
              fetchedCurrentLevel;
          fetchedCompletedLevels =
              userData['completedLevels'] ?? fetchedCompletedLevels;

          if (userData['completedChords'] is List) {
            fetchedCompletedChords = (userData['completedChords'] as List)
                .map((c) => c.toString())
                .toList();
          }
        } catch (_) {}
      }

      List<dynamic> levelsData = [];
      try {
        levelsData = await ApiService.getLearningPaths();
      } catch (_) {
        levelsData = [];
      }

      if (levelsData.isEmpty) {
        levelsData = _getFallbackLevels();
      }

      List<LevelData> loadedLevels = [];

      for (var item in levelsData) {
        int levelNum =
            (item['levelNumber'] ??
                    item['level_number'] ??
                    item['level'] as num?)
                ?.toInt() ??
            int.tryParse(item['levelNumber']?.toString() ?? '1') ??
            1;

        int requiredPoints = (item['requiredPoints'] as num?)?.toInt() ?? 0;

        List<String> chordList = [];
        if (item['chords'] is List) {
          chordList = (item['chords'] as List)
              .map((c) => c.toString())
              .toList();
        }

        double? progress;
        int? accuracy;

        dynamic matchedCompleted;
        for (var cl in fetchedCompletedLevels) {
          if (cl is Map) {
            int clNum =
                (cl['levelNumber'] ?? cl['level_number'] ?? cl['level'] as num?)
                    ?.toInt() ??
                -1;
            if (clNum == levelNum) {
              matchedCompleted = cl;
              break;
            }
          } else if (cl is num && cl.toInt() == levelNum) {
            matchedCompleted = {"levelNumber": levelNum, "progress": 1.0};
            break;
          }
        }

        bool isExplicitlyCompleted = false;

        if (matchedCompleted != null) {
          double rawProg =
              (matchedCompleted['progress'] as num?)?.toDouble() ?? 1.0;
          accuracy = (matchedCompleted['accuracy'] as num?)?.toInt();
          progress = rawProg >= 1.0 ? 1.0 : rawProg;
          isExplicitlyCompleted = progress == 1.0;
        } else if (levelNum < fetchedCurrentLevel) {
          progress = 1.0;
          isExplicitlyCompleted = true;
        }

        if (!isExplicitlyCompleted) {
          int count = chordList
              .where((c) => fetchedCompletedChords.contains(c))
              .length;

          if (chordList.isNotEmpty && count == chordList.length) {
            progress = 1.0;
            isExplicitlyCompleted = true;
          } else if (chordList.isNotEmpty && count > 0) {
            progress = (count / chordList.length).clamp(0.0, 1.0);
          } else if (levelNum == fetchedCurrentLevel) {
            progress = 0.0;
          } else if (fetchedPoints >= requiredPoints) {
            progress = 0.0;
          } else {
            progress = null;
          }
        }

        loadedLevels.add(
          LevelData(
            levelNumber: levelNum,
            title: item['title'] ?? "Level $levelNum",
            difficulty: item['difficulty'] ?? "Beginner",
            chords: chordList.isEmpty ? ["C Major", "G Major"] : chordList,
            requiredPoints: requiredPoints,
            rewardPoints: (item['rewardPoints'] as num?)?.toInt() ?? 100,
            progress: progress,
            accuracy: accuracy,
          ),
        );
      }

      loadedLevels.sort((a, b) => a.levelNumber.compareTo(b.levelNumber));

      setState(() {
        _userTotalPoints = fetchedPoints;
        _userCurrentLevel = fetchedCurrentLevel;
        _userCompletedLevels = fetchedCompletedLevels;
        _userCompletedChords = fetchedCompletedChords;
        _levels = loadedLevels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _openPractice(LevelData level) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeSessionScreen(
          initialChord: level.chords.first,
          userId: widget.userId ?? "6a72a3418427dadc19d157d",
          levelId: level.levelNumber,
          rewardPoints: level.rewardPoints,
          levelChords: List<String>.from(level.chords),
        ),
      ),
    );
    _fetchLearningPathData();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLevels = _levels.where((level) {
      if (_selectedFilter == "All") return true;
      return level.difficulty.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    int completedCount = _levels.where((l) => l.progress == 1.0).length;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    "Your Points",
                    "$_userTotalPoints",
                    const Color(0xFFA855F7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    "Levels Completed",
                    "$completedCount/${_levels.length}",
                    const Color(0xFF0EA5E9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                  )
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.triangle_alert,
                          color: Color(0xFFEF4444),
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchLearningPathData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                          ),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  )
                : filteredLevels.isEmpty
                ? const Center(
                    child: Text(
                      "No levels found for this filter.",
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filteredLevels.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildLevelCard(filteredLevels[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildLevelCard(LevelData level) {
    final bool isLocked = level.progress == null;
    final bool isCompleted = level.progress == 1.0;

    Color cardBorderColor = const Color(0xFF1E293B);
    if (isCompleted) {
      cardBorderColor = const Color(0xFF10B981).withOpacity(0.4);
    } else if (!isLocked && level.progress! > 0.0) {
      cardBorderColor = const Color(0xFF0EA5E9).withOpacity(0.4);
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
                            LucideIcons.check,
                            color: Color(0xFF10B981),
                            size: 22,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Level ${level.levelNumber}: ${level.title}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isLocked
                                    ? const Color(0xFF475569)
                                    : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isCompleted && level.accuracy != null)
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.star,
                                  color: Color(0xFF10B981),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${level.accuracy}%",
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLocked
                              ? const Color(0xFF1E293B)
                              : (level.difficulty.toLowerCase() == "beginner"
                                    ? const Color(0xFF064E3B)
                                    : const Color(0xFF78350F)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          level.difficulty,
                          style: TextStyle(
                            color: isLocked
                                ? const Color(0xFF64748B)
                                : (level.difficulty.toLowerCase() == "beginner"
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
                final isChordDone =
                    isCompleted || _userCompletedChords.contains(chord);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isLocked
                        ? const Color(0xFF1E293B).withOpacity(0.4)
                        : (isChordDone
                              ? const Color(0xFF064E3B).withOpacity(0.5)
                              : const Color(0xFF0C243B)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isLocked
                          ? const Color(0xFF334155)
                          : (isChordDone
                                ? const Color(0xFF10B981)
                                : const Color(0xFF0C4A6E)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.music,
                        color: isLocked
                            ? const Color(0xFF475569)
                            : (isChordDone
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF0EA5E9)),
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        chord,
                        style: TextStyle(
                          color: isLocked
                              ? const Color(0xFF475569)
                              : (isChordDone
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF38BDF8)),
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
            if (!isLocked && !isCompleted && level.progress != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: level.progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (isCompleted)
              _buildActionButton(
                label: "Review Level",
                icon: LucideIcons.arrow_right,
                onTap: () => _openPractice(level),
                colors: [const Color(0xFF00C853), const Color(0xFF00E676)],
              )
            else if (!isLocked)
              _buildActionButton(
                label: "Start Practice",
                icon: LucideIcons.arrow_right,
                onTap: () => _openPractice(level),
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
