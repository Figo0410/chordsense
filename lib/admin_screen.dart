import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex =
      2; // Default to Content Management to easily view changes
  int _contentSubTab = 0; // 0: Levels, 1: Songs, 2: Requests
  String _searchQuery = "";
  bool _maintenanceMode = false;

  // Mock Data
  final List<Map<String, dynamic>> _users = [
    {
      "name": "Joshua Williams",
      "email": "joshua@example.com",
      "level": "7",
      "points": "3,450",
      "rawPoints": 3450,
      "sessions": 47,
      "avatar": "J",
    },
    {
      "name": "Sarah Johnson",
      "email": "sarah@example.com",
      "level": "5",
      "points": "2,100",
      "rawPoints": 2100,
      "sessions": 32,
      "avatar": "S",
    },
    {
      "name": "Mike Chen",
      "email": "mike@example.com",
      "level": "9",
      "points": "5,200",
      "rawPoints": 5200,
      "sessions": 65,
      "avatar": "M",
    },
  ];

  final List<Map<String, dynamic>> _levels = [
    {
      "num": "1",
      "title": "Beginner I",
      "chords": ["C", "G", "D"],
      "accuracy": "70%",
      "points": "100 pts",
    },
    {
      "num": "2",
      "title": "Beginner II",
      "chords": ["Am", "Em", "Dm"],
      "accuracy": "75%",
      "points": "150 pts",
    },
    {
      "num": "3",
      "title": "Intermediate I",
      "chords": ["F", "A", "E"],
      "accuracy": "80%",
      "points": "200 pts",
    },
    {
      "num": "4",
      "title": "Intermediate II",
      "chords": ["Bm", "C7", "G7"],
      "accuracy": "85%",
      "points": "250 pts",
    },
  ];

  final List<Map<String, dynamic>> _songs = [
    {
      "title": "Alapaap",
      "artist": "Eraserheads",
      "level": "Beginner",
      "chords": "4 chords",
      "rawChords": "4",
      "status": "Active",
    },
    {
      "title": "Torete",
      "artist": "Moonstar88",
      "level": "Beginner",
      "chords": "4 chords",
      "rawChords": "4",
      "status": "Active",
    },
    {
      "title": "Huling El Bimbo",
      "artist": "Eraserheads",
      "level": "Intermediate",
      "chords": "5 chords",
      "rawChords": "5",
      "status": "Active",
    },
    {
      "title": "Tadhana",
      "artist": "Up Dharma Down",
      "level": "Intermediate",
      "chords": "5 chords",
      "rawChords": "5",
      "status": "Active",
    },
    {
      "title": "Kathang Isip",
      "artist": "Ben&Ben",
      "level": "Intermediate",
      "chords": "6 chords",
      "rawChords": "6",
      "status": "Active",
    },
  ];

  final List<Map<String, dynamic>> _requests = [
    {
      "title": "Ligaya",
      "artist": "Eraserheads",
      "user": "Joshua Williams",
      "date": "Mar 10, 2026",
      "tag": "Acoustic",
      "status": "Completed",
    },
    {
      "title": "Mundo",
      "artist": "IV of Spades",
      "user": "Sarah Johnson",
      "date": "Mar 18, 2026",
      "tag": "Rhythm",
      "status": "In Progress",
    },
    {
      "title": "Pagtingin",
      "artist": "Ben&Ben",
      "user": "Mike Chen",
      "date": "Mar 20, 2026",
      "tag": "Fingerstyle",
      "status": "Pending",
    },
    {
      "title": "Araw-Araw",
      "artist": "Ben&Ben",
      "user": "Emma Davis",
      "date": "Mar 22, 2026",
      "tag": "Acoustic",
      "status": "Pending",
    },
  ];

  // ==========================================
  // MODAL DIALOG HANDLERS
  // ==========================================

  void _showAddLevelDialog() {
    final titleController = TextEditingController();
    final chordsController = TextEditingController();
    final accuracyController = TextEditingController(text: "70");
    final pointsController = TextEditingController(text: "100");

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0D1425),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF1E293B)),
          ),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add New Level",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.x,
                        color: Color(0xFF64748B),
                        size: 18,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDialogLabel("Level Name"),
                const SizedBox(height: 6),
                _buildDialogTextField(
                  controller: titleController,
                  hintText: "e.g. Beginner I",
                ),
                const SizedBox(height: 16),
                _buildDialogLabel("Chords (comma-separated)"),
                const SizedBox(height: 6),
                _buildDialogTextField(
                  controller: chordsController,
                  hintText: "e.g. C, G, D, Am",
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDialogLabel("Min. Accuracy (%)"),
                          const SizedBox(height: 6),
                          _buildDialogTextField(controller: accuracyController),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDialogLabel("Points Reward"),
                          const SizedBox(height: 6),
                          _buildDialogTextField(controller: pointsController),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogCancelButton(
                        () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDialogGradientSubmitButton("Add Level", () {
                        if (titleController.text.isNotEmpty) {
                          setState(() {
                            final chordsList = chordsController.text
                                .split(",")
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();

                            _levels.add({
                              "num": "${_levels.length + 1}",
                              "title": titleController.text,
                              "chords": chordsList.isEmpty
                                  ? ["C", "G"]
                                  : chordsList,
                              "accuracy": "${accuracyController.text}%",
                              "points": "${pointsController.text} pts",
                            });
                          });
                        }
                        Navigator.pop(context);
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditLevelDialog(Map<String, dynamic> level, int index) {
    final titleController = TextEditingController(text: level["title"]);
    List<String> currentChords = List<String>.from(level["chords"]);
    final chordsController = TextEditingController(
      text: currentChords.join(", "),
    );
    final accuracyController = TextEditingController(
      text: level["accuracy"].replaceAll("%", ""),
    );
    final pointsController = TextEditingController(
      text: level["points"].replaceAll(" pts", ""),
    );

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: const Color(0xFF0D1425),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF1E293B)),
              ),
              child: Container(
                width: 440,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Edit Level",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            color: Color(0xFF64748B),
                            size: 18,
                          ),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDialogLabel("Level Name"),
                    const SizedBox(height: 6),
                    _buildDialogTextField(controller: titleController),
                    const SizedBox(height: 16),
                    _buildDialogLabel("Chords (comma-separated)"),
                    const SizedBox(height: 6),
                    _buildDialogTextField(
                      controller: chordsController,
                      onChanged: (val) {
                        setModalState(() {
                          currentChords = val
                              .split(",")
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: currentChords.map((chord) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF0284C7).withOpacity(0.5),
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
                              _buildDialogLabel("Min. Accuracy (%)"),
                              const SizedBox(height: 6),
                              _buildDialogTextField(
                                controller: accuracyController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDialogLabel("Points Reward"),
                              const SizedBox(height: 6),
                              _buildDialogTextField(
                                controller: pointsController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogCancelButton(
                            () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDialogGradientSubmitButton(
                            "Save Changes",
                            () {
                              setState(() {
                                _levels[index] = {
                                  "num": level["num"],
                                  "title": titleController.text,
                                  "chords": currentChords,
                                  "accuracy": "${accuracyController.text}%",
                                  "points": "${pointsController.text} pts",
                                };
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddSongDialog() {
    final titleController = TextEditingController();
    final artistController = TextEditingController();
    final chordsNumController = TextEditingController(text: "3");
    String selectedDifficulty = "Beginner";
    String selectedStatus = "Active";

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: const Color(0xFF0D1425),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF1E293B)),
              ),
              child: Container(
                width: 440,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add New Song",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            color: Color(0xFF64748B),
                            size: 18,
                          ),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDialogLabel("Song Title"),
                    const SizedBox(height: 6),
                    _buildDialogTextField(
                      controller: titleController,
                      hintText: "e.g. Alapaap",
                    ),
                    const SizedBox(height: 16),
                    _buildDialogLabel("Artist"),
                    const SizedBox(height: 6),
                    _buildDialogTextField(
                      controller: artistController,
                      hintText: "e.g. Eraserheads",
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDialogLabel("Difficulty"),
                              const SizedBox(height: 6),
                              _buildDialogDropdown(
                                value: selectedDifficulty,
                                items: ["Beginner", "Intermediate", "Advanced"],
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(
                                      () => selectedDifficulty = val,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDialogLabel("Number of Chords"),
                              const SizedBox(height: 6),
                              _buildDialogTextField(
                                controller: chordsNumController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDialogLabel("Status"),
                    const SizedBox(height: 6),
                    _buildDialogDropdown(
                      value: selectedStatus,
                      items: ["Active", "Inactive"],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedStatus = val);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogCancelButton(
                            () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDialogGradientSubmitButton(
                            "Add Song",
                            () {
                              if (titleController.text.isNotEmpty) {
                                setState(() {
                                  _songs.add({
                                    "title": titleController.text,
                                    "artist": artistController.text,
                                    "level": selectedDifficulty,
                                    "chords":
                                        "${chordsNumController.text} chords",
                                    "rawChords": chordsNumController.text,
                                    "status": selectedStatus,
                                  });
                                });
                              }
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditSongDialog(Map<String, dynamic> song, int index) {
    final titleController = TextEditingController(text: song["title"]);
    final artistController = TextEditingController(text: song["artist"]);
    final chordsNumController = TextEditingController(
      text: song["rawChords"] ?? "4",
    );
    String selectedDifficulty = song["level"];
    String selectedStatus = song["status"] ?? "Active";

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: const Color(0xFF0D1425),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF1E293B)),
              ),
              child: Container(
                width: 440,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Edit Song",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            color: Color(0xFF64748B),
                            size: 18,
                          ),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDialogLabel("Song Title"),
                    const SizedBox(height: 6),
                    _buildDialogTextField(controller: titleController),
                    const SizedBox(height: 16),
                    _buildDialogLabel("Artist"),
                    const SizedBox(height: 6),
                    _buildDialogTextField(controller: artistController),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDialogLabel("Difficulty"),
                              const SizedBox(height: 6),
                              _buildDialogDropdown(
                                value: selectedDifficulty,
                                items: ["Beginner", "Intermediate", "Advanced"],
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(
                                      () => selectedDifficulty = val,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDialogLabel("Number of Chords"),
                              const SizedBox(height: 6),
                              _buildDialogTextField(
                                controller: chordsNumController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDialogLabel("Status"),
                    const SizedBox(height: 6),
                    _buildDialogDropdown(
                      value: selectedStatus,
                      items: ["Active", "Inactive"],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedStatus = val);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogCancelButton(
                            () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDialogGradientSubmitButton(
                            "Save Changes",
                            () {
                              setState(() {
                                _songs[index] = {
                                  "title": titleController.text,
                                  "artist": artistController.text,
                                  "level": selectedDifficulty,
                                  "chords":
                                      "${chordsNumController.text} chords",
                                  "rawChords": chordsNumController.text,
                                  "status": selectedStatus,
                                };
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // DIALOG WIDGET HELPERS
  // ==========================================

  Widget _buildDialogLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    String? hintText,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF070B16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13),
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _buildDialogDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF070B16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF0D1425),
          icon: const Icon(
            LucideIcons.chevron_down,
            color: Color(0xFF64748B),
            size: 16,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          isExpanded: true,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDialogCancelButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: const Center(
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogGradientSubmitButton(String text, VoidCallback onTap) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ROOT BUILD METHOD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SIDEBAR
          _buildSidebar(),

          // MAIN CONTENT AREA
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 32,
                  right: 32,
                  top: 24,
                  bottom: 32,
                ),
                child: _buildCurrentView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardView();
      case 1:
        return _buildUserManagementView();
      case 2:
        return _buildContentManagementView();
      case 3:
        return _buildUsageReportView();
      case 4:
        return _buildSettingsView();
      default:
        return _buildPlaceholderView();
    }
  }

  // ==========================================
  // VIEW 0: DASHBOARD OVERVIEW
  // ==========================================
  Widget _buildDashboardView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dashboard Overview",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "System statistics and summary",
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 28),

        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = (constraints.maxWidth - 48) / 4;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildMetricCard(
                  width: cardWidth,
                  icon: LucideIcons.users,
                  iconColor: const Color(0xFF06B6D4),
                  value: "1,234",
                  label: "Total Users",
                ),
                _buildMetricCard(
                  width: cardWidth,
                  icon: LucideIcons.activity,
                  iconColor: const Color(0xFFA855F7),
                  value: "456",
                  label: "Active Today",
                ),
                _buildMetricCard(
                  width: cardWidth,
                  icon: LucideIcons.trending_up,
                  iconColor: const Color(0xFF22C55E),
                  value: "84%",
                  label: "Avg Accuracy",
                ),
                _buildMetricCard(
                  width: cardWidth,
                  icon: LucideIcons.music,
                  iconColor: const Color(0xFFEAB308),
                  value: "8,456",
                  label: "Practice Sessions",
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),

        LayoutBuilder(
          builder: (context, constraints) {
            final double panelWidth = (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActiveUsersPanel(panelWidth),
                _buildPopularChordsPanel(panelWidth),
              ],
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 1: USER MANAGEMENT
  // ==========================================
  Widget _buildUserManagementView() {
    final filteredUsers = _users.where((user) {
      final name = user["name"]!.toLowerCase();
      final email = user["email"]!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "User Management",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF070C18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.search,
                color: Color(0xFF64748B),
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: "Search users...",
                    hintStyle: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1120),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < filteredUsers.length; i++) ...[
                _buildUserListItem(filteredUsers[i]),
                if (i < filteredUsers.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 2: CONTENT MANAGEMENT
  // ==========================================
  Widget _buildContentManagementView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Content Management",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            _buildContentSubTab(0, "Levels"),
            const SizedBox(width: 8),
            _buildContentSubTab(1, "Songs"),
            const SizedBox(width: 8),
            _buildContentSubTab(2, "Requests"),
          ],
        ),
        const SizedBox(height: 24),

        if (_contentSubTab == 0) ...[
          _buildLevelsTab(),
        ] else if (_contentSubTab == 1) ...[
          _buildSongsTab(),
        ] else ...[
          _buildRequestsTab(),
        ],
      ],
    );
  }

  // SUB TAB 0: LEVELS
  Widget _buildLevelsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _buildGradientButton(
            text: "Add New Level",
            onTap: _showAddLevelDialog,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1120),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _levels.length; i++) ...[
                _buildLevelCard(_levels[i], i),
                if (i < _levels.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard(Map<String, dynamic> level, int index) {
    List<String> chords = List<String>.from(level["chords"]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF070C18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF0284C7).withOpacity(0.5),
              ),
            ),
            child: Center(
              child: Text(
                level["num"],
                style: const TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level["title"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Level ${level["num"]} • ${chords.length} Chords",
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      "Chords",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                    ),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 6,
                      children: chords.map((chord) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chord,
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Min. Accuracy",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  level["accuracy"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Points Reward",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  level["points"],
                  style: const TextStyle(
                    color: Color(0xFFA855F7),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildOutlinedButton(
            text: "Edit",
            onTap: () => _showEditLevelDialog(level, index),
          ),
        ],
      ),
    );
  }

  // SUB TAB 1: SONGS
  Widget _buildSongsTab() {
    int beginnerCount = _songs.where((s) => s["level"] == "Beginner").length;
    int intermediateCount = _songs
        .where((s) => s["level"] == "Intermediate")
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildMiniStatBadge(
                  "Total Songs",
                  "${_songs.length}",
                  Colors.white,
                ),
                const SizedBox(width: 10),
                _buildMiniStatBadge(
                  "Beginner",
                  "$beginnerCount",
                  const Color(0xFF22C55E),
                ),
                const SizedBox(width: 10),
                _buildMiniStatBadge(
                  "Intermediate",
                  "$intermediateCount",
                  const Color(0xFFEAB308),
                ),
              ],
            ),
            _buildGradientButton(
              text: "Add New Song",
              onTap: _showAddSongDialog,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1120),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _songs.length; i++) ...[
                _buildSongCard(_songs[i], i),
                if (i < _songs.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSongCard(Map<String, dynamic> song, int index) {
    final bool isBeginner = song["level"] == "Beginner";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF070C18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFA855F7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFA855F7).withOpacity(0.4),
              ),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.music,
                color: Color(0xFFA855F7),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song["title"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  song["artist"],
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isBeginner
                  ? const Color(0xFF22C55E).withOpacity(0.15)
                  : const Color(0xFFEAB308).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isBeginner
                    ? const Color(0xFF22C55E).withOpacity(0.5)
                    : const Color(0xFFEAB308).withOpacity(0.5),
              ),
            ),
            child: Text(
              song["level"],
              style: TextStyle(
                color: isBeginner
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEAB308),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            song["chords"],
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(width: 24),
          _buildOutlinedButton(
            text: "Edit",
            onTap: () => _showEditSongDialog(song, index),
          ),
          const SizedBox(width: 8),
          _buildOutlinedButton(
            text: "Delete",
            onTap: () {
              setState(() {
                _songs.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  // SUB TAB 2: REQUESTS
  Widget _buildRequestsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildMiniStatBadge(
              "Total Requests",
              "${_requests.length}",
              Colors.white,
            ),
            const SizedBox(width: 10),
            _buildMiniStatBadge(
              "Pending",
              "${_requests.where((r) => r["status"] == "Pending").length}",
              const Color(0xFFEAB308),
            ),
            const SizedBox(width: 10),
            _buildMiniStatBadge(
              "In Progress",
              "${_requests.where((r) => r["status"] == "In Progress").length}",
              const Color(0xFF06B6D4),
            ),
            const SizedBox(width: 10),
            _buildMiniStatBadge(
              "Completed",
              "${_requests.where((r) => r["status"] == "Completed").length}",
              const Color(0xFF22C55E),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1120),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _requests.length; i++) ...[
                _buildRequestCard(_requests[i]),
                if (i < _requests.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final String status = request["status"];

    Color statusBgColor;
    Color statusTextColor;

    if (status == "Completed") {
      statusBgColor = const Color(0xFF22C55E).withOpacity(0.15);
      statusTextColor = const Color(0xFF22C55E);
    } else if (status == "In Progress") {
      statusBgColor = const Color(0xFF06B6D4).withOpacity(0.15);
      statusTextColor = const Color(0xFF06B6D4);
    } else {
      statusBgColor = const Color(0xFFEAB308).withOpacity(0.15);
      statusTextColor = const Color(0xFFEAB308);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF070C18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                request["title"],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            request["artist"],
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "Requested by: ${request["user"]}",
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
              const Text(
                "  •  ",
                style: TextStyle(color: Color(0xFF475569), fontSize: 11),
              ),
              Text(
                request["date"],
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
              const Text(
                "  •  ",
                style: TextStyle(color: Color(0xFF475569), fontSize: 11),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  request["tag"],
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (status == "Completed") ...[
            Row(
              children: const [
                Icon(LucideIcons.trophy, color: Color(0xFF22C55E), size: 14),
                SizedBox(width: 6),
                Text(
                  "Request fulfilled",
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ] else if (status == "In Progress") ...[
            _buildGradientButton(
              text: "Mark as Completed",
              onTap: () {
                setState(() {
                  request["status"] = "Completed";
                });
              },
            ),
          ] else ...[
            Row(
              children: [
                _buildGradientButton(
                  text: "Mark In Progress",
                  onTap: () {
                    setState(() {
                      request["status"] = "In Progress";
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildOutlinedButton(text: "Reject", onTap: () {}),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 3: USAGE REPORT & ANALYTICS
  // ==========================================
  Widget _buildUsageReportView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Usage Report & Analytics",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 28),

        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = (constraints.maxWidth - 32) / 3;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildMetricCard(
                  width: cardWidth,
                  icon: LucideIcons.users,
                  iconColor: const Color(0xFF06B6D4),
                  value: "1,234",
                  label: "Total Users",
                ),
                _buildMetricCard(
                  width: cardWidth,
                  icon: LucideIcons.activity,
                  iconColor: const Color(0xFFA855F7),
                  value: "456",
                  label: "Daily Active",
                ),
                _buildMetricCard(
                  width: cardWidth,
                  icon: LucideIcons.music,
                  iconColor: const Color(0xFFEAB308),
                  value: "8,456",
                  label: "Practice Sessions",
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1120),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "User Activity",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "User",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Level",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Points",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Sessions",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF1E293B), height: 1),
              const SizedBox(height: 12),
              for (int i = 0; i < _users.length; i++) ...[
                _buildUsageUserRow(_users[i]),
                if (i < _users.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        LayoutBuilder(
          builder: (context, constraints) {
            final double summaryCardWidth = (constraints.maxWidth - 32) / 3;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildSummaryBox(
                  width: summaryCardWidth,
                  title: "Avg Level",
                  value: "7.0",
                  valueColor: const Color(0xFF06B6D4),
                ),
                _buildSummaryBox(
                  width: summaryCardWidth,
                  title: "Total Points",
                  value: "10,750",
                  valueColor: const Color(0xFFA855F7),
                ),
                _buildSummaryBox(
                  width: summaryCardWidth,
                  title: "Total Sessions",
                  value: "144",
                  valueColor: Colors.white,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildUsageUserRow(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF070C18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              user["name"]!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Lvl ${user["level"]}",
              style: const TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user["points"]!,
              style: const TextStyle(
                color: Color(0xFFA855F7),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "${user["sessions"]}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox({
    required double width,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 4: SETTINGS
  // ==========================================
  Widget _buildSettingsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1120),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "General system configuration and administrative controls.",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildSettingsButton(
                label: "Maintenance Mode: ${_maintenanceMode ? 'ON' : 'OFF'}",
                onTap: () {
                  setState(() {
                    _maintenanceMode = !_maintenanceMode;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildSettingsButton(
                label: "Clear System Cache",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("System cache cleared successfully"),
                      backgroundColor: Color(0xFF06B6D4),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildSettingsButton(
                label: "Factory Reset System Data",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Action cancelled for demo safety"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF070C18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // GENERAL HELPER COMPONENTS
  // ==========================================

  Widget _buildContentSubTab(int index, String label) {
    final bool isSelected = _contentSubTab == index;

    return InkWell(
      onTap: () {
        setState(() {
          _contentSubTab = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF070C18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF06B6D4)
                : const Color(0xFF1E293B),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatBadge(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF070C18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF0EA5E9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user["avatar"]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["name"]!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user["email"]!,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user["level"]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Level",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(width: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user["points"]!,
                style: const TextStyle(
                  color: Color(0xFF06B6D4),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Points",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Text(
          "Section coming soon",
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
      ),
    );
  }

  // SIDEBAR
  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF0B0F1D),
        border: Border(right: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF97316), Color(0xFFEF4444)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text("👑", style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Admin Panel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "ChordSense",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildSidebarItem(
                    index: 0,
                    icon: LucideIcons.chart_column,
                    label: "Dashboard",
                  ),
                  _buildSidebarItem(
                    index: 1,
                    icon: LucideIcons.users,
                    label: "User Management",
                  ),
                  _buildSidebarItem(
                    index: 2,
                    icon: LucideIcons.book_open,
                    label: "Content Management",
                  ),
                  _buildSidebarItem(
                    index: 3,
                    icon: LucideIcons.trending_up,
                    label: "Usage Report",
                  ),
                  _buildSidebarItem(
                    index: 4,
                    icon: LucideIcons.settings,
                    label: "Settings",
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: const [
                    Icon(
                      LucideIcons.log_out,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2E1B4E).withOpacity(0.5)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: const Color(0xFFA855F7).withOpacity(0.8),
                      width: 1.5,
                    )
                  : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required double width,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveUsersPanel(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Most Active Users",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildUserRow("Joshua Williams", "Level 7", "47 sessions"),
          const SizedBox(height: 10),
          _buildUserRow("Sarah Johnson", "Level 5", "32 sessions"),
          const SizedBox(height: 10),
          _buildUserRow("Mike Chen", "Level 9", "65 sessions"),
        ],
      ),
    );
  }

  Widget _buildUserRow(String name, String level, String sessions) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF070C18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                level,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ],
          ),
          Text(
            sessions,
            style: const TextStyle(
              color: Color(0xFF06B6D4),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularChordsPanel(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Popular Chords",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildChordRow("C Major", "450 practices"),
          const SizedBox(height: 10),
          _buildChordRow("G Major", "380 practices"),
          const SizedBox(height: 10),
          _buildChordRow("D Major", "320 practices"),
        ],
      ),
    );
  }

  Widget _buildChordRow(String chord, String practices) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF070C18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            chord,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            practices,
            style: const TextStyle(
              color: Color(0xFFA855F7),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
