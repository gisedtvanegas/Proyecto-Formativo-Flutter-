import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'client/http_client_factory.dart';

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
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

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
  }
}
