import 'package:flutter/foundation.dart';

class ApiConfig {
  // En Web, usamos el proxy local de Codespaces para evitar CORS (/api redirige al backend)
  // En móvil/desktop, apuntamos directamente a la URL de Railway (sin context-path)
  static const String baseUrl = kIsWeb 
      ? '/api/Cafeteriatalleres' 
      : 'https://casa-jardin-vivero-cafe-production-45e9.up.railway.app';
}
