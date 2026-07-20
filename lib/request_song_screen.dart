import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class SongRequest {
  final String songTitle;
  final String artist;
  final String trackType;
  final String requestedDate;
  final String status; // "Completed" or "In Progress"
  final String? completedDate;

  SongRequest({
    required this.songTitle,
    required this.artist,
    required this.trackType,
    required this.requestedDate,
    required this.status,
    this.completedDate,
  });
}

class RequestSongScreen extends StatefulWidget {
  const RequestSongScreen({super.key});

  @override
  State<RequestSongScreen> createState() => _RequestSongScreenState();
}

class _RequestSongScreenState extends State<RequestSongScreen> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();

  // Initial request list matching the screenshots
  final List<SongRequest> _myRequests = [
    SongRequest(
      songTitle: "Ligaya",
      artist: "Eraserheads",
      trackType: "Acoustic",
      requestedDate: "Mar 10, 2026",
      status: "Completed",
      completedDate: "Mar 15, 2026",
    ),
    SongRequest(
      songTitle: "Mundo",
      artist: "IV of Spades",
      trackType: "Acoustic",
      requestedDate: "Mar 18, 2026",
      status: "In Progress",
    ),
    SongRequest(
      songTitle: "Pagtingin",
      artist: "Ben&Ben",
      trackType: "Acoustic",
      requestedDate: "Mar 20, 2026",
      status: "In Progress",
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    final artist = _artistController.text.trim();

    if (title.isEmpty || artist.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in both Song Title and Artist."),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Add new request to the top of the list
    setState(() {
      _myRequests.insert(
        0,
        SongRequest(
          songTitle: title,
          artist: artist,
          trackType: "Acoustic",
          requestedDate: "Jul 20, 2026",
          status: "In Progress",
        ),
      );
    });

    // Clear input fields
    _titleController.clear();
    _artistController.clear();

    // Display "Request submitted successfully" pop-up dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
        title: Row(
          children: const [
            Icon(LucideIcons.circle_check, color: Color(0xFF10B981), size: 22),
            SizedBox(width: 8),
            Text(
              "Success",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          "Request submitted successfully",
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "OK",
              style: TextStyle(
                color: Color(0xFF38BDF8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
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
          "Request Guitar Track",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormCard(),
              const SizedBox(height: 24),
              _buildMyRequestsHeader(),
              const SizedBox(height: 12),
              ..._myRequests.map((req) => _buildRequestCard(req)),
              const SizedBox(height: 16),
              _buildHowItWorksCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B4B).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF312E81)),
                ),
                child: const Icon(
                  LucideIcons.music,
                  color: Color(0xFF38BDF8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "New Request",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Request a song to be added to the library",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Song Title Input
          const Text(
            "Song Title *",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: "Enter song title",
              hintStyle: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xFF0B1120),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1E293B)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0EA5E9)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Artist Input
          const Text(
            "Artist *",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _artistController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: "Enter artist name",
              hintStyle: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xFF0B1120),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1E293B)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0EA5E9)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Guitar Track Type (Locked to Acoustic)
          const Text(
            "Guitar Track Type",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF082F49).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0EA5E9)),
            ),
            child: const Center(
              child: Text(
                "Acoustic",
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(LucideIcons.send, color: Colors.white, size: 14),
                      SizedBox(width: 8),
                      Text(
                        "Submit Request",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
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

  Widget _buildMyRequestsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "My Requests",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${_myRequests.length} requests",
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRequestCard(SongRequest request) {
    final bool isCompleted = request.status == "Completed";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF059669).withOpacity(0.6)
              : const Color(0xFF1E293B),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.songTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    request.artist,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B4B).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.music,
                  color: Color(0xFFA855F7),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Track Type Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF082F49).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF0EA5E9).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  request.trackType,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Status Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF065F46).withOpacity(0.4)
                      : const Color(0xFF78350F).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCompleted
                          ? LucideIcons.circle_check
                          : LucideIcons.clock,
                      size: 10,
                      color: isCompleted
                          ? const Color(0xFF34D399)
                          : const Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.status,
                      style: TextStyle(
                        color: isCompleted
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFBBF24),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF1E293B), height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Requested: ${request.requestedDate}",
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
              if (isCompleted && request.completedDate != null)
                Text(
                  "Completed: ${request.completedDate}",
                  style: const TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF082F49).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("💡", style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How it works",
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Submit your song requests and our team will review them. Once approved, we'll add the guitar track to the library with chord progressions and guided play features.",
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
