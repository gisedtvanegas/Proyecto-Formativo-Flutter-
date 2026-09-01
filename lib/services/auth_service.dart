<<<<<<< HEAD
import 'package:supabase_flutter/supabase_flutter.dart';
=======
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'client/http_client_factory.dart';
>>>>>>> origin/main

/// Resultado tipado del intento de login
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
<<<<<<< HEAD
=======
  // Singleton
>>>>>>> origin/main
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

<<<<<<< HEAD
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
=======
  final http.Client _client = getClient();

  // Nombre del usuario autenticado (disponible tras login exitoso)
  String? nombreUsuario;

  /// Inicia sesión contra el backend Railway.
  /// Devuelve [LoginResult] con éxito/error y el nombre del usuario si está disponible.
  Future<LoginResult> login(String document, String password) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/Iniciar');

      print('--- [LOGIN DIAGNOSTIC] ---');
      print('URL: $url');
      print('Método: POST');
      print('Campo usuario: $document');

      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'usuario': document, 'pass': password},
      );

      print('HTTP Status: ${response.statusCode}');
      print('Redirect: ${response.isRedirect}');
      print('Response length: ${response.body.length} bytes');

      // Analizar el HTML devuelto
      final doc = html_parser.parse(response.body);

      // ── Detectar mensaje de error real del backend ──────────────────────────
      // El backend devuelve: <p class="mensaje">El documento no existe</p>
      // o mensajes similares en caso de fallo
      final mensajeEl = doc.querySelector('p.mensaje');
      if (mensajeEl != null) {
        final texto = mensajeEl.text.trim();
        print('Mensaje del backend: $texto');
        if (texto.isNotEmpty) {
          // El backend reportó un error específico
          return LoginResult.fail(texto);
        }
      }

      // ── Si la respuesta sigue mostrando el formulario de login, falló ──────
      final hayFormLogin = doc.querySelector('form[action="/Iniciar"]') != null ||
          doc.querySelector('form[action*="Iniciar"]') != null;

      if (hayFormLogin && response.statusCode == 200) {
        // Hubo formulario de login sin mensaje — algo salió mal
        print('Login Result: FAILED (formulario de login sigue presente)');
        return LoginResult.fail('No se pudo iniciar sesión. Verifica tus credenciales.');
      }

      // ── Login exitoso: intentar extraer el nombre del usuario ───────────────
      // Buscar el nombre en elementos típicos del HTML post-login:
      // navbar, bienvenida, título de sección, etc.
      String? nombre = _extraerNombreDeHtml(doc, response.body);
      print('Nombre extraído del HTML de login: $nombre');
      print('Login Result: SUCCESS');

      nombreUsuario = nombre;
      return LoginResult.ok(nombre: nombre);
    } catch (e) {
      print('Error de conexión en login: $e');
      return LoginResult.fail('Error de conexión: $e');
    }
  }

  /// Intenta extraer el nombre del usuario del HTML de la respuesta post-login.
  /// El backend es un JSP que renderiza el nombre en lugares típicos.
  String? _extraerNombreDeHtml(dynamic doc, String rawHtml) {
    // Estrategia 1: buscar elementos típicos de bienvenida
    final selectoresBienvenida = [
      'span.usuario',
      'span.nombre',
      '.nombre-usuario',
      '.usuario-nombre',
      '#nombreUsuario',
      '#usuario',
      'p.bienvenida',
      '.bienvenida',
    ];
    for (final selector in selectoresBienvenida) {
      final el = doc.querySelector(selector);
      if (el != null && el.text.trim().isNotEmpty) {
        return el.text.trim();
      }
    }

    // Estrategia 2: buscar texto "Hola" o "Bienvenido" en el HTML
    final regex = RegExp(
      r'(?:hola|bienvenido|bienvenida)[,:\s]+([A-Za-záéíóúÁÉÍÓÚñÑ\s]+)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(rawHtml);
    if (match != null) {
      final nombre = match.group(1)?.trim().split(RegExp(r'[<!\n]')).first.trim();
      if (nombre != null && nombre.isNotEmpty && nombre.length < 50) {
        return nombre;
      }
    }

    // Estrategia 3: nombre en el <title> de la página de destino
    final title = doc.querySelector('title')?.text ?? '';
    if (title.isNotEmpty &&
        !title.toLowerCase().contains('inicio de sesión') &&
        !title.toLowerCase().contains('iniciar')) {
      // Si el título cambió, podría contener el nombre
      return null; // No inferir del título para evitar falsos positivos
    }

    return null; // No se encontró el nombre en el HTML de login
  }

  /// Permite guardar el nombre después de que ReservaService lo extraiga del HTML autenticado
  void setNombreUsuario(String nombre) {
    nombreUsuario = nombre;
  }

  void logout() {
    nombreUsuario = null;
    // La cookie JSESSIONID es HttpOnly — el backend debe invalidarla.
    // En desarrollo local podemos solo limpiar el estado local.
>>>>>>> origin/main
  }
}
