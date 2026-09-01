import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'widgets/app_background.dart';

class MisReservasPage extends StatefulWidget {
  const MisReservasPage({super.key});

  @override
  State<MisReservasPage> createState() => _MisReservasPageState();
}

class _MisReservasPageState extends State<MisReservasPage> {
  late Future<List<Map<String, dynamic>>> _reservasFuture;

  @override
  void initState() {
    super.initState();
    _reservasFuture = AuthService().getReservasByCurrentUser();
  }

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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _reservasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'No se pudieron cargar las reservas.',
                  style: TextStyle(
                    color: Color(0xFF173F5B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            final reservas = snapshot.data ?? const <Map<String, dynamic>>[];

            if (reservas.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No tienes reservas asociadas a esta cuenta.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173F5B),
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: reservas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reserva = reservas[index];
                final numPersonas = reserva['num_personas'] ?? 'N/A';
                final hora = reserva['hora'] ?? 'N/A';
                final fecha = reserva['fecha'] ?? 'N/A';
                final activo = reserva['activo'] == true ? 'Activa' : 'Inactiva';

                return Card(
                  color: Colors.white.withOpacity(0.92),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reserva #${reserva['idreserva'] ?? index + 1}',
                          style: const TextStyle(
                            color: Color(0xFF173F5B),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Fecha: $fecha'),
                        Text('Hora: $hora'),
                        Text('Personas: $numPersonas'),
                        Text('Estado: $activo'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
