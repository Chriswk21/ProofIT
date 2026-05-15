import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class ProjectApiService {
  static String get baseUrl => '${AppConfig.baseUrl}/projects';

  // Ambil daftar anggota tim
  Future<List<Map<String, dynamic>>> getProjectMembers(String projectId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$projectId/members"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print("getProjectMembers error: ${response.statusCode} - ${response.body}");
      throw Exception("Gagal memuat tim dari server");
    }
  }

  // Tambah anggota ke proyek
  Future<bool> addProjectMember(String projectId, String userId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/members"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "project_id": projectId,
        "user_id": userId,
      }),
    );

    print("addProjectMember status: ${response.statusCode} - ${response.body}");
    return response.statusCode == 201;
  }

  // Hapus anggota dari proyek
  Future<bool> removeProjectMember(String projectId, String userId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/$projectId/members/$userId"),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("removeProjectMember error: ${response.statusCode} - ${response.body}");
      throw Exception("Gagal menghapus anggota");
    }
  }

  Future<bool> finalizeProject(String projectId) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/$projectId/finalize"),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("finalizeProject error: ${response.statusCode} - ${response.body}");
      throw Exception("Gagal menyelesaikan proyek di server");
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableUsers(String projectId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$projectId/available-users"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print("getAvailableUsers error: ${response.statusCode} - ${response.body}");
      throw Exception("Gagal memuat daftar user");
    }
  }
}