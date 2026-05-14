import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class ApiNotification {
  static String get baseUrl => '${AppConfig.baseUrl}/notifications';

  //notificationCount
  static Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/unread-count/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['unread_count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print("Error fetching unread count: $e");
      return 0;
    }
  }


  static Future<List<Map<String, dynamic>>> getNotifications(
    String userId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$userId'),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List data = decoded['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> markNotificationsAsRead(String userId) async {
    await http.post(Uri.parse('$baseUrl/mark-read/$userId'));
  }

  static Future<void> markAsRead(String notifId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/read/$notifId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal update status baca");
    }
  }
}
