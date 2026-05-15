import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class ApiStorage {
  static String get baseUrl => '${AppConfig.baseUrl}/forum';

  static Future<Map<String, dynamic>> uploadFile(
    List<int> bytes,
    String fileName,
  ) async {
  
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload'), 
    );

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("ALASAN DITOLAK: ${response.body}"); 
        throw Exception('Gagal upload file: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat upload: $e');
    }
  }
}