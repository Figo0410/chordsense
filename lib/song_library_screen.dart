import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'guided_play_screen.dart'; // Import GuidedPlayScreen widget
import 'request_song_screen.dart'; // Import RequestSongScreen widget

enum Difficulty { all, beginner, intermediate }

class Song {
  final String title;
  final String artist;
  final Difficulty difficulty;
  final int chordCount;
  final int durationMinutes;
  final List<String> chords;

  Song({
    required this.title,
    required this.artist,
    required this.difficulty,
    required this.chordCount,
    required this.durationMinutes,
    required this.chords,
  });
}

class SongLibraryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SongLibraryScreen({super.key, this.onBack});

  @override
  State<SongLibraryScreen> createState() => _SongLibraryScreenState();
}

class _SongLibraryScreenState extends State<SongLibraryScreen> {
  Difficulty _selectedDifficulty = Difficulty.all;

  // Complete song list matching the attached screenshots
  final List<Song> _allSongs = [
    Song(
      title: "Alapaap",
      artist: "Eraserheads",
      difficulty: Difficulty.beginner,
      chordCount: 4,
      durationMinutes: 3,
      chords: ["G", "D", "Em", "C"],
    ),
    Song(
      title: "Torete",
      artist: "Moonstar88",
      difficulty: Difficulty.beginner,
      chordCount: 4,
      durationMinutes: 4,
      chords: ["C", "G", "Am", "F"],
    ),
    Song(
      title: "Narda",
      artist: "Kamikazee",
      difficulty: Difficulty.beginner,
      chordCount: 4,
      durationMinutes: 3,
      chords: ["Em", "C", "G", "D"],
    ),
    Song(
      title: "Huling El Bimbo",
      artist: "Eraserheads",
      difficulty: Difficulty.intermediate,
      chordCount: 5,
      durationMinutes: 6,
      chords: ["C#m", "A", "E", "B", "F#m"],
    ),
    Song(
      title: "Pare Ko",
      artist: "Eraserheads",
      difficulty: Difficulty.beginner,
      chordCount: 4,
      durationMinutes: 4,
      chords: ["E", "A", "B", "C#m"],
    ),
    Song(
      title: "Tadhana",
      artist: "Up Dharma Down",
      difficulty: Difficulty.intermediate,
      chordCount: 5,
      durationMinutes: 5,
      chords: ["Bm", "A", "G", "D", "Em"],
    ),
    Song(
      title: "With a Smile",
      artist: "Eraserheads",
      difficulty: Difficulty.beginner,
      chordCount: 5,
      durationMinutes: 4,
      chords: ["C", "G", "Am", "F", "Dm"],
    ),
    Song(
      title: "Harana",
      artist: "Parokya ni Edgar",
      difficulty: Difficulty.beginner,
      chordCount: 5,
      durationMinutes: 5,
      chords: ["C", "G", "Am", "Em", "F"],
    ),
    Song(
      title: "Binibini",
      artist: "Zack Tabudlo",
      difficulty: Difficulty.intermediate,
      chordCount: 5,
      durationMinutes: 4,
      chords: ["F#m", "A", "E", "D", "Bm"],
    ),
    Song(
      title: "Kathang Isip",
      artist: "Ben&Ben",
      difficulty: Difficulty.intermediate,
      chordCount: 6,
      durationMinutes: 6,
      chords: ["C", "Em", "Am", "F", "G", "Dm"],
    ),
  ];

  List<Song> get _filteredSongs {
    if (_selectedDifficulty == Difficulty.all) {
      return _allSongs;
    }
    return _allSongs
        .where((song) => song.difficulty == _selectedDifficulty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedSongs = _filteredSongs;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14), // Deep dark background
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildFilterSection(),
                    const SizedBox(height: 20),
                    _buildSubHeader(displayedSongs.length),
                    const SizedBox(height: 16),
                    ...displayedSongs.map((song) => _buildSongCard(song)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.onBack != null || Navigator.canPop(context))
                IconButton(
                  icon: const Icon(
                    LucideIcons.arrow_left,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (widget.onBack != null || Navigator.canPop(context))
                const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Song Library",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Learn to play Filipino songs",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFFA855F7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.music, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(LucideIcons.funnel, color: Color(0xFF94A3B8), size: 14),
            SizedBox(width: 6),
            Text(
              "Filter by Difficulty",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildFilterChip("All", Difficulty.all),
            const SizedBox(width: 8),
            _buildFilterChip("Beginner", Difficulty.beginner),
            const SizedBox(width: 8),
            _buildFilterChip("Intermediate", Difficulty.intermediate),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, Difficulty difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = difficulty),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
                )
              : null,
          color: isSelected ? null : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFF1E293B),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSubHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$count songs available",
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        TextButton(
          onPressed: () {
            // Action for song request
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RequestSongScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7).withOpacity(0.15),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Request Song",
            style: TextStyle(
              color: Color(0xFF38BDF8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSongCard(Song song) {
    final bool isBeginner = song.difficulty == Difficulty.beginner;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Square Icon Box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B4B).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF312E81)),
                ),
                child: const Icon(
                  LucideIcons.music,
                  color: Color(0xFFA855F7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Title & Artist
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Difficulty Badge & Meta info
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isBeginner
                                ? const Color(0xFF065F46).withOpacity(0.4)
                                : const Color(0xFF78350F).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isBeginner
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                          child: Text(
                            isBeginner ? "Beginner" : "Intermediate",
                            style: TextStyle(
                              color: isBeginner
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFFBBF24),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${song.chordCount} chords • ${song.durationMinutes} min",
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Chord Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: song.chords
                .map(
                  (chord) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF082F49).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF0EA5E9).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      chord,
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          // Gradient Play Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                // Trigger Guided Play logic
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GuidedPlayScreen(
                      songTitle: song.title,
                      artist: song.artist,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: ZeroPadding.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(LucideIcons.play, color: Colors.white, size: 14),
                      SizedBox(width: 8),
                      Text(
                        "Start Guided Play",
                        style: TextStyle(
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
          ),
        ],
      ),
    );
  }
}

// Helper class to remove padding inside Ink buttons cleanly
class ZeroPadding {
  static const EdgeInsets zero = EdgeInsets.zero;
}
