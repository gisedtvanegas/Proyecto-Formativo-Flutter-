import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'widgets/app_background.dart';

class MisReservasPage extends StatelessWidget {
  const MisReservasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        backgroundColor: const Color(0xFF5F72A6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              AuthService().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: AppBackground(
        child: const Center(
          child: Text(
            'Próximamente: Lista de reservas.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173F5B),
            ),
          ),
        ),
      ),
    );
  }
}
