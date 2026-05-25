class AppConfig {
  // URL Server Backend Railway Anda yang sedang online
  static const String productionUrl = 'https://gregarious-playfulness-production-e7df.up.railway.app/api';

  // Dikunci agar selalu mengarah ke server Railway online saat dijalankan lokal maupun production
  static String get baseUrl => productionUrl;
}
