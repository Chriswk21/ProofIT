import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class ApiForum {
  static String get baseUrl => '${AppConfig.baseUrl}/forum';

  static Future<List<dynamic>> getMessages(String projectId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$projectId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Error Fetch Forum: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error Fetch Forum: $e");
      return [];
    }
  }

  // Kirim pesan baru
  static Future<bool> sendMessage(Map<String, dynamic> messageData) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(messageData),
      );
      print("sendMessage status: ${response.statusCode} - ${response.body}");
      return response.statusCode == 201;
    } catch (e) {
      print("Error Send Message: $e");
      return false;
    }
  }

  //Edit pesan
  static Future<bool> editMessage(String messageId, String newMessage) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$messageId'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"message": newMessage}),
      );
      print("editMessage status: ${response.statusCode} - ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("Error Edit Message: $e");
      return false;
    }
  }

  //Hapus pesan
  static Future<bool> deleteMessage(String messageId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$messageId'));
      print("deleteMessage status: ${response.statusCode} - ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("Error Delete Message: $e");
      return false;
    }
  }
}
