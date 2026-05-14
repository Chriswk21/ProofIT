import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/data_models.dart';
import 'app_config.dart';

class ApiUser {
  static String get baseUrl => '${AppConfig.baseUrl}/users';

  // --- 1. GET ALL USERS ---
  static Future<List<User>> getAllUsers() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map<User>((item) => User.fromJson(item)).toList();
    } else {
      throw Exception("Gagal mengambil data user");
    }
  }

  
  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- 2. CREATE USER ---
  static Future<bool> createUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password_hash': password,
        'role': role,
      }),
    );
    return response.statusCode == 201;
  }

  // --- 3. UPDATE USER ---
  static Future<bool> updateUser({
    required String id,
    required String username,
    required String email,
    required String role,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'role': role}),
    );
    return response.statusCode == 200;
  }

  // --- 4. DELETE USER ---
  static Future<bool> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }
}
