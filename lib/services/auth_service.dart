import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'client/http_client_factory.dart';

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Usa el cliente proveído por el factory (BrowserClient en Web, estándar en Mobile)
  final http.Client _client = getClient();

  /// Inicia sesión enviando usuario y clave al backend
  Future<bool> login(String document, String password) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/Iniciar');
      
      print('--- [LOGIN DIAGNOSTIC] ---');
      print('URL: $url');
      print('Method: POST');
      
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'usuario': document,
          'pass': password,
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Is Redirect: ${response.isRedirect}');
      print('Headers: ${response.headers.keys.toList()}'); // Only log header keys safely

      // Evaluamos el éxito sin leer Set-Cookie.
      // El backend en Java con JSP suele redirigir (302) o devolver 200 con un HTML.
      // Si devuelve HTML con "incorrectos" o algo similar, falló.
      final bodyLower = response.body.toLowerCase();
      
      if (response.statusCode >= 200 && response.statusCode < 400) {
        if (bodyLower.contains('usuario o contraseña incorrectos') || 
            bodyLower.contains('datos incorrectos')) {
          print('Login Result: FAILED (Credenciales incorrectas en HTML)');
          return false;
        }
        
        // Si no hay mensaje de error y el status es OK o Redirección, asumimos éxito
        print('Login Result: SUCCESS');
        return true;
      }
      
      print('Login Result: FAILED (Status Code ${response.statusCode})');
      return false;
    } catch (e) {
      print('--- [LOGIN DIAGNOSTIC] ---');
      print('Error de conexión: $e');
      return false;
    }
  }

  /// Limpia la sesión
  void logout() {
    // Si estamos en web, no podemos borrar la cookie httponly manualmente
    // Podríamos requerir un endpoint de logout en el backend.
    // Por ahora solo cerramos sesión local visualmente.
  }
}

