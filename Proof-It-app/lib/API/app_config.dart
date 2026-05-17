import 'package:flutter/foundation.dart' show kIsWeb;
class AppConfig {
  static String get host => kIsWeb ? 'localhost' : '10.0.2.2';
  static String get baseUrl => 'http://$host:3000/api';
}
