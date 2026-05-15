// lib/screens/team_page.dart

import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../data/mock_database.dart';
import 'package:main/API/api_user.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // MENGAMBIL DATA USER 
  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final List<User> fetchedUsers = await ApiUser.getAllUsers();

      if (mounted) {
        setState(() {
          _users = fetchedUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal mengambil data: $e")));
      }
    }
  }

  // MENAMBAHKAN USER 
  void _showAddUserDialog() {
    final name = TextEditingController();
    final email = TextEditingController();
    final pass = TextEditingController();
    UserRole role = UserRole.Member;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDst) => AlertDialog(
          title: const Text("Add New User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: pass,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 10),
              DropdownButton<UserRole>(
                value: role,
                isExpanded: true,
                items: UserRole.values
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(r.toString().split('.').last),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setDst(() => role = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final success = await ApiUser.createUser(
                    username: name.text,
                    email: email.text,
                    password: pass.text,
                    role: role.toString().split('.').last,
                  );

                  if (mounted && success) {
                    Navigator.pop(context);
                    _fetchUsers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("User berhasil ditambahkan!"),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Create User"),
            ),
          ],
        ),
      ),
    );
  }

  //MENGUPDATE USER
  void _showEditUserDialog(User user) {
    final name = TextEditingController(text: user.username);
    final email = TextEditingController(text: user.email);
    UserRole role = user.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDst) => AlertDialog(
          title: const Text("Edit User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),
              DropdownButton<UserRole>(
                value: role,
                isExpanded: true,
                items: UserRole.values
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(r.toString().split('.').last),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setDst(() => role = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final success = await ApiUser.updateUser(
                    id: user.id,
                    username: name.text,
                    email: email.text,
                    role: role.toString().split('.').last,
                  );

                  if (success && mounted) {
                    Navigator.pop(context);
                    _fetchUsers(); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User berhasil diupdate!")),
                    );
                  } else if (mounted) {
                    throw Exception("Gagal mengupdate user di server");
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                }
              },
              child: const Text("Update User"),
            ),
          ],
        ),
      ),
    );
  }

  // MENGHAPUS USER (BARU)
  Future<void> _deleteUser(User userToDelete) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Hapus Akun Karyawan?"),
        content: Text(
          "Apakah Anda yakin ingin menghapus akun '${userToDelete.username}' secara permanen?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(c, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await ApiUser.deleteUser(userToDelete.id);
        if (success) {
          _fetchUsers();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User berhasil dihapus!")),
            );
          }
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Gagal menghapus user: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthSession.currentUser!;
    final canManage = currentUser.role == UserRole.Admin;

    return Scaffold(
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: _showAddUserDialog,
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _users.length,
              separatorBuilder: (c, i) => const Divider(),
              itemBuilder: (c, i) {
                final u = _users[i];
                final isMe =
                    u.id == currentUser.id;

                Color roleColor = Colors.grey;
                if (u.role == UserRole.Admin) roleColor = Colors.red;
                if (u.role == UserRole.PIC) roleColor = Colors.orange;
                if (u.role == UserRole.Member) roleColor = Colors.blue;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    child: Text(
                      u.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        u.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "You",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.email),
                      const SizedBox(height: 4),
                      Text(
                        u.role.toString().split('.').last,
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: canManage
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditUserDialog(u),
                            ),
                            if (!isMe) 
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteUser(u),
                              ),
                          ],
                        )
                      : null,
                );
              },
            ),
    );
  }
}
