import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import 'widgets/app_background.dart';

class MisReservasPage extends StatefulWidget {
  final String? nombreUsuario;

  const MisReservasPage({super.key, this.nombreUsuario});

  @override
  State<MisReservasPage> createState() => _MisReservasPageState();
}

class _MisReservasPageState extends State<MisReservasPage> {
  late Future<List<Map<String, dynamic>>> _reservasFuture;

  String? get _nombre => widget.nombreUsuario ?? AuthService().nombreUsuario;

  @override
  void initState() {
    super.initState();
    _reservasFuture = AuthService().getReservasByCurrentUser();
  }

  Future<void> _refreshReservas() async {
    setState(() {
      _reservasFuture = AuthService().getReservasByCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mis Reservas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_nombre != null && _nombre!.isNotEmpty)
              Text(
                'Hola, $_nombre!',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF5F72A6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReservas,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              AuthService().logout();
              if (!mounted) return;
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

            if (snapshot.hasError || !snapshot.hasData) {
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
                final fecha = reserva['fecha'] ?? 'N/A';
                final hora = reserva['hora'] ?? 'N/A';
                final personas = reserva['num_personas'] ?? reserva['personas'] ?? 'N/A';
                final estado = reserva['activo'] == true ? 'Activa' : 'Inactiva';

                return Card(
                  color: Colors.white.withValues(alpha: 0.92),
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
                        Text('Personas: $personas'),
                        Text('Estado: $estado'),
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
