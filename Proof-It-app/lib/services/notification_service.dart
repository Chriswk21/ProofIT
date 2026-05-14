import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/mock_database.dart';

class NotificationService {
  static final supabase = Supabase.instance.client;


  static Future<void> send({
    required String userId,
    required String type,
    required String title,
    required String message,
    String? projectId,
    String? taskId,
  }) async {
    try {
      await supabase.from('notifications').insert({
        'user_id': userId,
        'type': type,
        'title': title,
        'message': message,
        if (projectId != null) 'project_id': projectId,
        if (taskId != null) 'task_id': taskId,
        'is_read': false,
      });
    } catch (e) {
      print("Gagal kirim notifikasi: $e");
    }
  }

  static Future<void> sendToMany({
    required List<String> userIds,
    required String type,
    required String title,
    required String message,
    String? projectId,
    String? taskId,
  }) async {
    try {
      final notifications = userIds
          .map(
            (uid) => {
              'user_id': uid,
              'type': type,
              'title': title,
              'message': message,
              if (projectId != null) 'project_id': projectId,
              if (taskId != null) 'task_id': taskId,
              'is_read': false,
            },
          )
          .toList();

      await supabase.from('notifications').insert(notifications);
    } catch (e) {
      print("Gagal kirim notifikasi massal: $e");
    }
  }

  static Future<void> markAllAsRead(String userId) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print("Gagal mark as read: $e");
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print("Gagal mark as read: $e");
    }
  }
}
