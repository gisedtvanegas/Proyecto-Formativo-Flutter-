import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/reserva.dart';
import 'auth_service.dart';

class ReservaService {
  static final ReservaService _instance = ReservaService._internal();
  factory ReservaService() => _instance;
  ReservaService._internal();

  SupabaseClient get supabase => Supabase.instance.client;

  Future<ReservaResult> obtenerReservas() async {
    final userId = AuthService().currentUserId;
    if (userId == null) {
      return ReservaResult.error('No hay usuario autenticado.');
    }

    try {
      final response = await supabase
          .from('reserva')
          .select()
          .eq('usuarios_idusuarios', userId)
          .order('idreserva', ascending: true);

      final rows = response as List<dynamic>? ?? const [];
      final reservas = rows
          .whereType<Map<String, dynamic>>()
          .map((item) => Reserva(
                idReserva: item['idreserva']?.toString() ?? '',
                fecha: item['fecha']?.toString() ?? '',
                hora: item['hora']?.toString() ?? '',
                numPersonas: item['num_personas']?.toString() ??
                    item['personas']?.toString() ??
                    '',
                estado: item['activo'] == true ? 'Activa' : 'Inactiva',
              ))
          .toList();

      return ReservaResult.success(reservas);
    } catch (_) {
      return ReservaResult.error('No se pudieron cargar las reservas.');
    }
  }
}

class ReservaResult {
  final List<Reserva> reservas;
  final String? errorMessage;
  final bool sessionExpired;

  const ReservaResult._({
    required this.reservas,
    this.errorMessage,
    this.sessionExpired = false,
  });

  factory ReservaResult.success(List<Reserva> reservas) =>
      ReservaResult._(reservas: reservas);

  factory ReservaResult.error(String message) =>
      ReservaResult._(reservas: [], errorMessage: message);

  factory ReservaResult.sessionExpired() =>
      ReservaResult._(reservas: [], sessionExpired: true);

  bool get isSuccess => errorMessage == null && !sessionExpired;
}
