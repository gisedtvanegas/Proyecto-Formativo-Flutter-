import 'package:flutter/material.dart';

import 'widgets/app_background.dart';
import 'widgets/brand_header.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void _closeSession(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrandHeader(
                  title: 'Panel administrador',
                  trailing: IconButton.filledTonal(
                    tooltip: 'Cerrar sesión',
                    onPressed: () => _closeSession(context),
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Casa y Jardín',
                  style: TextStyle(
                    color: Color(0xFF255D72),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vivero - Café',
                  style: TextStyle(
                    color: Color(0xFF173F5B),
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 34),
                const _AdminOptionGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminOptionGrid extends StatelessWidget {
  const _AdminOptionGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        if (isWide) {
          return Row(
            children: const [
              Expanded(
                child: _AdminOption(
                  icon: Icons.event_available_outlined,
                  title: 'Reservas',
                  action: 'Ver reservas',
                  details: ['Disponibilidad', 'Horario'],
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _AdminOption(
                  icon: Icons.groups_2_outlined,
                  title: 'Usuarios',
                  action: 'Ver usuarios',
                  details: ['Tipo documento', 'Roles'],
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _AdminOption(
                  icon: Icons.local_activity_outlined,
                  title: 'Actividad',
                  action: 'Ver actividades',
                  details: ['Tipo actividad', 'Lista precios'],
                ),
              ),
            ],
          );
        }

        return const Column(
          children: [
            _AdminOption(
              icon: Icons.event_available_outlined,
              title: 'Reservas',
              action: 'Ver reservas',
              details: ['Disponibilidad', 'Horario'],
            ),
            SizedBox(height: 18),
            _AdminOption(
              icon: Icons.groups_2_outlined,
              title: 'Usuarios',
              action: 'Ver usuarios',
              details: ['Tipo documento', 'Roles'],
            ),
            SizedBox(height: 18),
            _AdminOption(
              icon: Icons.local_activity_outlined,
              title: 'Actividad',
              action: 'Ver actividades',
              details: ['Tipo actividad', 'Lista precios'],
            ),
          ],
        );
      },
    );
  }
}

class _AdminOption extends StatelessWidget {
  const _AdminOption({
    required this.icon,
    required this.title,
    required this.action,
    required this.details,
  });

  final IconData icon;
  final String title;
  final String action;
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 176),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8D9).withOpacity(0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF255D72), size: 34),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF173F5B),
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            action,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF173F5B),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          for (final detail in details)
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF3C6E75),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
