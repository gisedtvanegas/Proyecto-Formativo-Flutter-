import 'package:flutter/material.dart';

import 'pages/admin_home_page.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const CasaJardinApp());
}

class CasaJardinApp extends StatelessWidget {
  const CasaJardinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Casa y Jardín',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C5C73),
          primary: const Color(0xFF2C5C73),
          secondary: const Color(0xFF6F83B2),
        ),
        scaffoldBackgroundColor: const Color(0xFFE4F6D4),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginPage(),
        '/admin': (_) => const AdminHomePage(),
      },
    );
  }
}
