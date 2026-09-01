import 'package:supabase_flutter/supabase_flutter.dart';

class LoginResult {
  final bool success;
  final String? errorMessage;
  final String? nombreUsuario;

  const LoginResult._({
    required this.success,
    this.errorMessage,
    this.nombreUsuario,
  });

  factory LoginResult.ok({String? nombre}) =>
      LoginResult._(success: true, nombreUsuario: nombre);

  factory LoginResult.fail(String message) =>
      LoginResult._(success: false, errorMessage: message);
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SupabaseClient get supabase => Supabase.instance.client;

  String? nombreUsuario;
  String? currentDocument;
  Map<String, dynamic>? currentUser;
  int? currentUserId;

  final List<String> credentialSearchTables = const ['usuarios'];
  final List<String> documentColumns = const ['documento'];
  final List<String> passwordColumns = const ['clave'];

  bool matchesPassword(String rawPassword, String storedPassword) {
    final normalizedRaw = rawPassword.trim();
    final normalizedStored = storedPassword.trim();

    if (normalizedRaw.isEmpty || normalizedStored.isEmpty) {
      return false;
    }

    return normalizedRaw == normalizedStored;
  }

  String normalizeDocument(String value) => value.trim();

  Future<LoginResult> login(String document, String password) async {
    try {
      final normalizedDocument = normalizeDocument(document);
      final normalizedPassword = password.trim();

      if (normalizedDocument.isEmpty || normalizedPassword.isEmpty) {
        return LoginResult.fail('Ingrese documento y clave.');
      }

      final rows = await supabase.from('usuarios').select();
      final data = rows as List<dynamic>?;

      if (data == null) {
        return LoginResult.fail('No se pudo consultar la tabla usuarios.');
      }

      for (final item in data) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        final storedDocument = normalizeDocument('${item['documento'] ?? ''}');
        if (storedDocument != normalizedDocument) {
          continue;
        }

        final storedPassword = '${item['clave'] ?? ''}';
        if (matchesPassword(normalizedPassword, storedPassword)) {
          currentDocument = normalizedDocument;
          currentUser = item;
          currentUserId = item['idusuarios'] is int ? item['idusuarios'] as int : null;

          final nombre = [
            item['nombre'] ?? '',
            item['apellido'] ?? '',
          ].where((value) => value.toString().trim().isNotEmpty).join(' ');

          nombreUsuario = nombre.isNotEmpty ? nombre : null;
          return LoginResult.ok(nombre: nombreUsuario);
        }
      }

      return LoginResult.fail('Usuario o contraseña incorrectos.');
    } catch (_) {
      return LoginResult.fail('Error de conexión con Supabase.');
    }
  }

  Future<List<Map<String, dynamic>>> getReservasByCurrentUser() async {
    final userId = currentUserId;
    if (userId == null) {
      return const [];
    }

    try {
      final response = await supabase
          .from('reserva')
          .select()
          .eq('usuarios_idusuarios', userId);

      final rows = response as List<dynamic>?;
      if (rows == null) {
        return const [];
      }

      return rows.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return const [];
    }
  }

  void setNombreUsuario(String nombre) {
    nombreUsuario = nombre;
  }

  Future<void> logout() async {
    currentDocument = null;
    currentUser = null;
    currentUserId = null;
    nombreUsuario = null;
  }
}
