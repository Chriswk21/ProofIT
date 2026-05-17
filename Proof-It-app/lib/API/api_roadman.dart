import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class RoadmapApiService {
  static String get baseUrl => '${AppConfig.baseUrl}/roadmap';

  Future<Map<String, dynamic>> fetchRoadmap(String userId, String role) async {
    final uri = Uri.parse('$baseUrl?userId=$userId&role=$role');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal ambil data roadmap (${response.statusCode}): ${response.body}');
    }
  }

  Future<Map<String, dynamic>> saveTask(Map<String, dynamic> taskData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/task'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(taskData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal simpan task (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final response = await http.delete(Uri.parse('$baseUrl/task/$taskId'));

    if (response.statusCode != 200) {
      throw Exception('Gagal hapus task (${response.statusCode}): ${response.body}');
    }
  }
}
