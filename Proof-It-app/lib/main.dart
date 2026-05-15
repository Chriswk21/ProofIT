import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_screen.dart';
import 'pages/main_layout.dart';
import 'data/mock_database.dart';
import 'models/data_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qpaicltxcyzuluciidpe.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwYWljbHR4Y3l6dWx1Y2lpZHBlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5NDkwNzAsImV4cCI6MjA4ODUyNTA3MH0.05Jpe9ky62Jsyzolea499_AXDBBU3s10v0WvcYPoqD4',
  );

  // Cek sesi tersimpan
  Widget initialScreen = const LoginScreen();
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final userDataStr = prefs.getString('user_data');

    if (token != null && userDataStr != null) {
      final userData = jsonDecode(userDataStr);
      
      UserRole roleEnum = UserRole.Member;
      if (userData['role'] == 'Admin') roleEnum = UserRole.Admin;
      if (userData['role'] == 'PIC') roleEnum = UserRole.PIC;

      AuthSession.currentUser = User(
        id: userData['id'].toString(),
        username: userData['username'].toString(),
        email: userData['email'].toString(),
        password: userData['password_hash']?.toString() ?? '',
        role: roleEnum,
      );
      
      initialScreen = const MainLayout();
    }
  } catch (e) {
    // Abaikan jika error, fallback ke LoginScreen
  }

  runApp(ProofItApp(initialScreen: initialScreen));
}

class ProofItApp extends StatelessWidget {
  final Widget initialScreen;
  const ProofItApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proof It!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
        fontFamily: 'Segoe UI',
        useMaterial3: true,
      ),
      home: initialScreen,
    );
  }  
}
