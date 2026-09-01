import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SupabaseClient get supabase => Supabase.instance.client;

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

  Future<bool> _loginByDatabase(String document, String password) async {
    try {
      final rows = await supabase.from('usuarios').select();
      final data = rows as List<dynamic>?;

      if (data == null) {
        return false;
      }

      for (final item in data) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        final storedDocument = normalizeDocument(
          (item['documento'] ?? '').toString(),
        );

        if (storedDocument != normalizeDocument(document)) {
          continue;
        }

        final storedPassword = (item['clave'] ?? '').toString();
        if (matchesPassword(password, storedPassword)) {
          currentUser = item;
          currentUserId = item['idusuarios'] is int ? item['idusuarios'] as int : null;
          return true;
        }
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  Future<bool> login(String document, String password) async {
    try {
      final normalizedDocument = normalizeDocument(document);
      final normalizedPassword = password.trim();

      if (normalizedDocument.isEmpty || normalizedPassword.isEmpty) {
        return false;
      }

      final databaseLogin = await _loginByDatabase(
        normalizedDocument,
        normalizedPassword,
      );

      if (databaseLogin) {
        currentDocument = normalizedDocument;
        return true;
      }

      return false;
    } catch (_) {
      return false;
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

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (_) {
      // Ignorar errores de cierre de sesión.
    }
    currentDocument = null;
    currentUser = null;
    currentUserId = null;
  }
}

