import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // 1. GET PROJECTS
  static Future<List<dynamic>> getProjects() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/projects'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Error Fetch status: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error Fetch: $e");
      return [];
    }
  }

  // 2. ADD PROJECT
  static Future<bool> addProject(
    String title,
    String desc,
    String status,
    String location,
    String startDate,
    String endDate,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projects'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "description": desc,
          "status": status,
          "location": location,
          "start_date": startDate,
          "end_date": endDate,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error Add: $e");
      return false;
    }
  }

  // 3. DELETE PROJECT
  static Future<bool> deleteProject(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/projects/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print("Error Delete: $e");
      return false;
    }
  }
}


