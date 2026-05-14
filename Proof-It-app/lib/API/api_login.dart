import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class ApiLogin {
  static String get baseUrl => '${AppConfig.baseUrl}/users';
  
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return responseData['user'];
        } else {
          return null; 
        }
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }
}
