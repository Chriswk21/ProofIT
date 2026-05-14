import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/data_models.dart';
import '../data/mock_database.dart';
import '../services/notification_service.dart';
import 'roadmap_page.dart';
import 'forum_page.dart';
import 'package:main/API/api_project.dart';

class ProjectDetailPage extends StatefulWidget {
  final EventModel event;
  const ProjectDetailPage({super.key, required this.event});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final ProjectApiService _apiService = ProjectApiService();
  late EventModel _evt;
  bool _isFinalizing = false;

  List<Map<String, dynamic>> _teamMembers = [];
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _evt = widget.event;
    _fetchTeamMembers();
  }

  Future<void> _fetchTeamMembers() async {
    setState(() => _isLoadingMembers = true);
    try {
      final response = await _apiService.getProjectMembers(_evt.id);

      if (mounted) {
        setState(() {
          _teamMembers = List<Map<String, dynamic>>.from(response);
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMembers = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat tim: $e")));
      }
    }
  }

  Future<void> _showAddMemberDialog() async {
    final availableUsers = await _apiService.getAvailableUsers(_evt.id);

    String? selectedUserId;
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDst) => AlertDialog(
          title: const Text("Add Team Member"),
          content: availableUsers.isEmpty
              ? const Text(
                  "Semua user di database sudah tergabung dalam proyek ini.",
                )
              : DropdownButton<String>(
                  value: selectedUserId,
                  hint: const Text("Pilih Karyawan/Staff"),
                  isExpanded: true,
                  items: availableUsers
                      .map(
                        (u) => DropdownMenuItem<String>(
                          value: u['id'].toString(),
                          child: Text("${u['username']} (${u['email']})"),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDst(() => selectedUserId = v),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            if (availableUsers.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  if (selectedUserId != null) {
                    final success = await _apiService.addProjectMember(
                      _evt.id,
                      selectedUserId!,
                    );

                    if (success && mounted) {
                      Navigator.pop(ctx);
                      _fetchTeamMembers(); 
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Berhasil menambahkan anggota!"),
                        ),
                      );
                    }
                  }
                },
                child: const Text("Add Member"),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _finalizeProject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Finalize Project?"),
        content: const Text(
          "Apakah Anda yakin ingin menyelesaikan proyek ini? Status akan berubah menjadi Completed.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Finalize!"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isFinalizing = true);
      try {
        final success = await _apiService.finalizeProject(_evt.id);

        if (success) {
          setState(() {
            _evt.status = 'Completed';
            _isFinalizing = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Proyek berhasil diselesaikan! 🎉")),
            );
          }
        }
      } catch (e) {
        setState(() => _isFinalizing = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthSession.currentUser!;
    final canManage = user.role == UserRole.Admin || user.role == UserRole.PIC;
    final isCompleted = _evt.status == 'Completed';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: Text(_evt.title),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    _evt.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: isCompleted
                      ? Colors.green
                      : (_evt.status == 'Upcoming'
                            ? Colors.orange
                            : Colors.blue),
                ),
                if (canManage && !isCompleted)
                  ElevatedButton.icon(
                    onPressed: _isFinalizing ? null : _finalizeProject,
                    icon: _isFinalizing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_circle),
                    label: const Text("Finalize Project"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _infoTile(
                  Icons.calendar_today,
                  "Deadline",
                  DateFormat('dd MMM yyyy').format(_evt.date),
                ),
                const SizedBox(width: 10),
                _infoTile(Icons.location_on, "Location", _evt.location),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                _evt.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Team Members",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _isLoadingMembers
                ? const Center(child: CircularProgressIndicator())
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ..._teamMembers.map((m) {
                        final userData = m['users'];
                        final isMe = m['user_id'] == user.id;
                        return Chip(
                          avatar: CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Text(
                              userData['username'][0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          label: Text(
                            "${userData['username']} ${isMe ? '(You)' : ''}",
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                          onDeleted: (canManage && !isMe)
                              ? () async {
                                  final success = await _apiService
                                      .removeProjectMember(
                                        _evt.id,
                                        m['user_id'],
                                      );
                                  if (success) _fetchTeamMembers();
                                }
                              : null,
                        );
                      }),
                      if (canManage)
                        ActionChip(
                          avatar: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.indigo,
                          ),
                          label: const Text(
                            "Add Member",
                            style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.indigo.shade50,
                          side: const BorderSide(color: Colors.indigo),
                          onPressed: _showAddMemberDialog,
                        ),
                    ],
                  ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ForumPage(event: _evt)),
                  );
                },
                icon: const Icon(Icons.forum),
                label: const Text("Open Project Forum"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: const Text("Project Roadmap")),
                        body: RoadmapPage(initialProjectId: _evt.id),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text("View Project Roadmap (Gantt Chart)"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              val,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
