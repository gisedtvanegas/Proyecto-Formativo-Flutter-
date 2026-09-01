import 'package:flutter_test/flutter_test.dart';
import 'package:flutterererere/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('detecta la estructura real de la tabla usuarios', () {
      final service = AuthService();

      expect(service.credentialSearchTables, contains('usuarios'));
      expect(service.documentColumns, contains('documento'));
      expect(service.passwordColumns, contains('clave'));
    });

    test('valida contra la contraseña almacenada sin depender de hashing externo', () {
      final service = AuthService();

      expect(service.matchesPassword('miClave123', 'miClave123'), isTrue);
      expect(service.matchesPassword('miClave123', 'otraClave'), isFalse);
    });

    test('normaliza la identificación antes de comparar', () {
      final service = AuthService();

      expect(service.normalizeDocument('  12345  '), '12345');
    });
  });
}
