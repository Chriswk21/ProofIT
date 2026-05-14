import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qpaicltxcyzuluciidpe.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwYWljbHR4Y3l6dWx1Y2lpZHBlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5NDkwNzAsImV4cCI6MjA4ODUyNTA3MH0.05Jpe9ky62Jsyzolea499_AXDBBU3s10v0WvcYPoqD4',
  );

  runApp(const ProofItApp());
}

class ProofItApp extends StatelessWidget {
  const ProofItApp({super.key});

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
      home: const LoginScreen(),
    );
    
  }  
}
