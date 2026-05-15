import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:main/API/api_notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/mock_database.dart';
import 'login_screen.dart';
import 'dashboard_page.dart';
import 'roadmap_page.dart';
import 'team_page.dart';
import 'notifications_page.dart';
//import 'package:main/API/api_service.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _idx;
  int _unreadCount = 0;
  RealtimeChannel? _notifChannel;

  @override
  void initState() {
    super.initState();
    _idx = widget.initialIndex;
    _refreshNotifications();
    _subscribeToNotifications();
  }

  @override
  void dispose() {
    _notifChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _refreshNotifications() async {
    final userId = AuthSession.currentUser?.id ?? '';
    if (userId.isEmpty) return;

    final count = await ApiNotification.getUnreadNotificationCount(userId);
    if (mounted) {
      setState(() => _unreadCount = count);
    }
  }

  void _subscribeToNotifications() {
    final userId = AuthSession.currentUser?.id ?? '';
    final supabase = Supabase.instance.client;
    _notifChannel = supabase
        .channel('notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            if (mounted) {
              setState(() => _unreadCount++);
              final title = payload.newRecord['title']?.toString() ?? '';
              final message = payload.newRecord['message']?.toString() ?? '';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              message,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.indigo,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: "Lihat",
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      ).then((_) => _refreshNotifications());
                    },
                  ),
                ),
              );
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            if (mounted) _refreshNotifications();
            _showNotificationSnackBar(payload.newRecord);
          },
        )
        .subscribe();
  }

  void _showNotificationSnackBar(Map<String, dynamic> data) {
    final title = data['title'] ?? 'New Notification';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
        backgroundColor: Colors.indigo,
        action: SnackBarAction(
          label: "Lihat",
          onPressed: () => /* navigate */ {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthSession.currentUser!;
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.indigo),
                const SizedBox(width: 10),
                const Text(
                  "Proof It!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.indigo,
                  ),
                ),
                const Spacer(),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsPage(),
                          ),
                        ).then((_) => _refreshNotifications());
                      },
                      icon: const Icon(Icons.notifications_none),
                    ),
                    if (_unreadCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            _unreadCount > 99 ? '99+' : '$_unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.indigo,
                  radius: 16,
                  child: Text(
                    user.username[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton(
                  child: Row(
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  itemBuilder: (c) => [
                    PopupMenuItem(
                      child: const Text("Logout"),
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: IndexedStack(
              index: _idx,
              children: const [DashboardPage(), RoadmapPage(), TeamPage()],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_view_week),
            label: "Roadmap",
          ),
          NavigationDestination(icon: Icon(Icons.people), label: "Team"),
        ],
      ),
    );
  }
}
