import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'guided_play_screen.dart';
import 'request_song_screen.dart';
import 'services/api_service.dart';

enum Difficulty { all, beginner, intermediate, advanced }

class Song {
  final String id;
  final String title;
  final String artist;
  final Difficulty difficulty;
  final String description;
  final int chordCount;
  final int durationMinutes;
  final List<String> chords;
  final List<String> progression;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.difficulty,
    required this.description,
    required this.chordCount,
    required this.durationMinutes,
    required this.chords,
    required this.progression,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    Difficulty diff = Difficulty.beginner;
    final levelVal = (json['difficulty'] ?? json['level'] ?? '')
        .toString()
        .toLowerCase();

    if (levelVal == 'intermediate') {
      diff = Difficulty.intermediate;
    } else if (levelVal == 'advanced') {
      diff = Difficulty.advanced;
    }

    List<String> parsedChords = [];
    final chordsData = json['chords'];

    if (chordsData is List) {
      parsedChords = chordsData.map((c) => c.toString()).toList();
    } else if (chordsData is String && chordsData.isNotEmpty) {
      parsedChords = chordsData.split(',').map((c) => c.trim()).toList();
    }

    List<String> parsedProgression = [];
    final progressionData = json['progression'];
    if (progressionData is List) {
      for (var item in progressionData) {
        if (item is Map && item.containsKey('chord')) {
          parsedProgression.add(item['chord'].toString());
        } else if (item is String) {
          parsedProgression.add(item);
        }
      }
    }

    if (parsedProgression.isEmpty) {
      parsedProgression = List.from(parsedChords);
    }

    return Song(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Untitled Song',
      artist: json['artist'] ?? 'Unknown Artist',
      difficulty: diff,
      description: json['description'] ?? 'No description available.',
      chordCount: parsedChords.length,
      durationMinutes: json['durationMinutes'] ?? 3,
      chords: parsedChords,
      progression: parsedProgression,
    );
  }
}

class SongLibraryScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final String? userId;

  const SongLibraryScreen({super.key, this.onBack, this.userId});

  @override
  State<SongLibraryScreen> createState() => _SongLibraryScreenState();
}

class _SongLibraryScreenState extends State<SongLibraryScreen> {
  Difficulty _selectedDifficulty = Difficulty.all;
  List<Song> _allSongs = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchSongsFromBackend();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSongsFromBackend() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final songsJson = await ApiService.getSongs();
      setState(() {
        _allSongs = songsJson.map((json) => Song.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Song> get _filteredSongs {
    return _allSongs.where((song) {
      final matchesDifficulty =
          _selectedDifficulty == Difficulty.all ||
          song.difficulty == _selectedDifficulty;

      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query);

      return matchesDifficulty && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedSongs = _filteredSongs;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF0EA5E9),
                onRefresh: _fetchSongsFromBackend,
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF0EA5E9)),
                            SizedBox(height: 12),
                            Text(
                              "Loading songs...",
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.triangle_alert,
                                color: Colors.redAccent,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Unable to load songs.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _fetchSongsFromBackend,
                                icon: const Icon(
                                  LucideIcons.rotate_ccw,
                                  size: 16,
                                ),
                                label: const Text("Try Again"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0EA5E9),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            _buildSearchBar(),
                            const SizedBox(height: 16),
                            _buildFilterSection(),
                            const SizedBox(height: 20),
                            _buildSubHeader(displayedSongs.length),
                            const SizedBox(height: 16),
                            if (displayedSongs.isEmpty)
                              _buildEmptyState()
                            else
                              ...displayedSongs.map(
                                (song) => _buildSongCard(song),
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: "Search by song title or artist...",
          hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          prefixIcon: const Icon(
            LucideIcons.search,
            color: Color(0xFF64748B),
            size: 18,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    LucideIcons.x,
                    color: Color(0xFF64748B),
                    size: 16,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = "";
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip("All", Difficulty.all),
              const SizedBox(width: 8),
              _buildFilterChip("Beginner", Difficulty.beginner),
              const SizedBox(width: 8),
              _buildFilterChip("Intermediate", Difficulty.intermediate),
              const SizedBox(width: 8),
              _buildFilterChip("Advanced", Difficulty.advanced),
            ],
          ),
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

  Widget _buildEmptyState() {
    final isSearching = _searchQuery.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? LucideIcons.search_x : LucideIcons.music,
            color: const Color(0xFF64748B),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            isSearching ? "No songs found." : "No songs available yet.",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isSearching
                ? "Try searching for a different song title or artist."
                : "Check back later for new guitar chords!",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSongCard(Song song) {
    final String diffLabel = song.difficulty == Difficulty.beginner
        ? "Beginner"
        : song.difficulty == Difficulty.intermediate
        ? "Intermediate"
        : "Advanced";

    final Color diffColor = song.difficulty == Difficulty.beginner
        ? const Color(0xFF34D399)
        : song.difficulty == Difficulty.intermediate
        ? const Color(0xFFFBBF24)
        : const Color(0xFFF87171);

    final Color diffBg = song.difficulty == Difficulty.beginner
        ? const Color(0xFF065F46).withOpacity(0.4)
        : song.difficulty == Difficulty.intermediate
        ? const Color(0xFF78350F).withOpacity(0.4)
        : const Color(0xFF7F1D1D).withOpacity(0.4);

    final Color diffBorder = song.difficulty == Difficulty.beginner
        ? const Color(0xFF059669)
        : song.difficulty == Difficulty.intermediate
        ? const Color(0xFFD97706)
        : const Color(0xFFDC2626);

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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: diffBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: diffBorder),
                          ),
                          child: Text(
                            diffLabel,
                            style: TextStyle(
                              color: diffColor,
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
          if (song.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              song.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
          const SizedBox(height: 12),
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
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GuidedPlayScreen(
                      lessonData: {
                        'userId': widget.userId,
                        'title': song.title,
                        'artist': song.artist,
                        'chords': song.progression.isNotEmpty
                            ? song.progression
                            : song.chords,
                      },
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

class ZeroPadding {
  static const EdgeInsets zero = EdgeInsets.zero;
}
