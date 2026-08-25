import 'package:flutter/material.dart';
import '../models/reserva.dart';
import '../services/auth_service.dart';
import '../services/reserva_service.dart';
import 'login_page.dart';
import 'widgets/app_background.dart';

class MisReservasPage extends StatefulWidget {
  final String? nombreUsuario;
  const MisReservasPage({super.key, this.nombreUsuario});

  @override
  State<MisReservasPage> createState() => _MisReservasPageState();
}

class _MisReservasPageState extends State<MisReservasPage> {
  final ReservaService _reservaService = ReservaService();

  List<Reserva> _reservas = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _sessionExpired = false;

  // Nombre del usuario: viene del login o se obtiene de /ReservaUsuario
  String? get _nombre =>
      widget.nombreUsuario ?? AuthService().nombreUsuario;

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  Future<void> _cargarReservas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _sessionExpired = false;
    });

    final result = await _reservaService.obtenerReservas();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.sessionExpired) {
        _sessionExpired = true;
      } else if (result.errorMessage != null) {
        _errorMessage = result.errorMessage;
      } else {
        _reservas = result.reservas;
      }
    });
  }

  void _cerrarSesion() {
    AuthService().logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
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
            onPressed: _isLoading ? null : _cargarReservas,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: AppBackground(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF5F72A6)),
            SizedBox(height: 16),
            Text(
              'Cargando reservas...',
              style: TextStyle(
                color: Color(0xFF173F5B),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_sessionExpired) {
      return _buildMensajeCentrado(
        icono: Icons.lock_outline,
        titulo: 'Sesión expirada',
        subtitulo: 'Tu sesión ha terminado. Por favor inicia sesión nuevamente.',
        accion: TextButton.icon(
          onPressed: _cerrarSesion,
          icon: const Icon(Icons.login),
          label: const Text('Ir al login'),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildMensajeCentrado(
        icono: Icons.error_outline,
        titulo: 'No se pudieron cargar las reservas',
        subtitulo: _errorMessage!,
        accion: TextButton.icon(
          onPressed: _cargarReservas,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      );
    }

    if (_reservas.isEmpty) {
      return _buildMensajeCentrado(
        icono: Icons.calendar_today_outlined,
        titulo: 'No tienes reservas',
        subtitulo: 'Cuando realices una reserva, aparecerá aquí.',
        accion: TextButton.icon(
          onPressed: _cargarReservas,
          icon: const Icon(Icons.refresh),
          label: const Text('Actualizar'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarReservas,
      color: const Color(0xFF5F72A6),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reservas.length,
        itemBuilder: (context, index) => _ReservaCard(reserva: _reservas[index]),
      ),
    );
  }

  Widget _buildMensajeCentrado({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    Widget? accion,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 64, color: const Color(0xFF5F72A6).withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173F5B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF173F5B).withValues(alpha: 0.7),
              ),
            ),
            if (accion != null) ...[
              const SizedBox(height: 20),
              accion,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta de reserva ──────────────────────────────────────────────────────────
class _ReservaCard extends StatelessWidget {
  final Reserva reserva;

  const _ReservaCard({required this.reserva});

  Color _colorEstado(String estado) {
    final e = estado.toLowerCase();
    if (e.contains('activ') || e.contains('confirm') || e.contains('aprobad')) {
      return Colors.green.shade700;
    }
    if (e.contains('cancel') || e.contains('rechaz') || e.contains('inactiv')) {
      return Colors.red.shade600;
    }
    if (e.contains('pend') || e.contains('espera')) {
      return Colors.orange.shade700;
    }
    return const Color(0xFF5F72A6);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado: ID + Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (reserva.idReserva.isNotEmpty)
                  Text(
                    'Reserva #${reserva.idReserva}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF173F5B),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _colorEstado(reserva.estado).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _colorEstado(reserva.estado), width: 1),
                  ),
                  child: Text(
                    reserva.estado.isNotEmpty ? reserva.estado : 'Sin estado',
                    style: TextStyle(
                      color: _colorEstado(reserva.estado),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            // Datos de la reserva
            _Dato(icono: Icons.calendar_today, etiqueta: 'Fecha', valor: reserva.fecha),
            const SizedBox(height: 8),
            _Dato(icono: Icons.access_time, etiqueta: 'Hora', valor: reserva.hora),
            const SizedBox(height: 8),
            _Dato(icono: Icons.people_outline, etiqueta: 'Personas', valor: reserva.numPersonas),
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _Dato({required this.icono, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 18, color: const Color(0xFF5F72A6)),
        const SizedBox(width: 8),
        Text(
          '$etiqueta: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF173F5B),
          ),
        ),
        Expanded(
          child: Text(
            valor.isNotEmpty ? valor : '—',
            style: const TextStyle(fontSize: 14, color: Color(0xFF2C2C2C)),
          ),
        ),
      ],
    );
  }
}
