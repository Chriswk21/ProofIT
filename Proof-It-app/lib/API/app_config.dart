import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class AppConfig {
  // Ganti URL ini dengan URL domain publik dari Railway Anda
  static const String productionUrl = 'https://gregarious-playfulness-production-e7df.up.railway.app/api';
  
  static String get host => kIsWeb ? 'localhost' : '10.0.2.2';
  static String get localUrl => 'http://$host:3000/api';

  static String get baseUrl => kReleaseMode ? productionUrl : localUrl;
}
