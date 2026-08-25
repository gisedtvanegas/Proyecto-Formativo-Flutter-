import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../config/api_config.dart';
import '../models/reserva.dart';
import 'client/http_client_factory.dart';
import 'package:http/http.dart' as http;

class ReservaService {
  static final ReservaService _instance = ReservaService._internal();
  factory ReservaService() => _instance;
  ReservaService._internal();

  // Reutiliza el mismo cliente HTTP que el Login (BrowserClient con withCredentials=true en Web)
  final http.Client _client = getClient();

  Future<ReservaResult> obtenerReservas() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/ReservaUsuario');

      print('--- [RESERVAS DIAGNOSTIC] ---');
      print('URL: $url');

      final response = await _client.get(url);

      print('Status Code: ${response.statusCode}');
      print('Content-Type: ${response.headers['content-type']}');
      print('HTML length: ${response.body.length} bytes');

      // Si el servidor redirigió a login, la sesión no está activa
      final bodyLower = response.body.toLowerCase();
      if (bodyLower.contains('iniciar sesion') ||
          bodyLower.contains('iniciar sesión') ||
          bodyLower.contains('ingresar') && bodyLower.contains('contraseña')) {
        print('WARN: La respuesta parece ser la página de Login — sesión no activa.');
        return ReservaResult.sessionExpired();
      }

      if (response.statusCode >= 200 && response.statusCode < 400) {
        // Log de las primeras líneas del HTML para diagnóstico
        final preview = response.body.length > 500
            ? response.body.substring(0, 500)
            : response.body;
        print('HTML preview (500 chars): $preview');

        final reservas = _parseHtml(response.body);
        print('Reservas encontradas: ${reservas.length}');
        return ReservaResult.success(reservas);
      }

      print('Error HTTP: ${response.statusCode}');
      return ReservaResult.error('Error del servidor: ${response.statusCode}');
    } catch (e) {
      print('Error de conexión en ReservaService: $e');
      return ReservaResult.error('Error de conexión: $e');
    }
  }

  List<Reserva> _parseHtml(String htmlContent) {
    final List<Reserva> reservas = [];

    try {
      final document = html_parser.parse(htmlContent);

      // ── Estrategia 1: buscar tabla con cabeceras de reserva ──
      final tables = document.getElementsByTagName('table');
      print('Tablas encontradas en HTML: ${tables.length}');

      Element? targetTable;
      for (final table in tables) {
        final text = table.text.toLowerCase();
        if (text.contains('fecha') || text.contains('hora') || text.contains('reserva')) {
          targetTable = table;
          print('Tabla de reservas localizada.');
          break;
        }
      }

      if (targetTable != null) {
        final parsed = _parseTable(targetTable);
        if (parsed.isNotEmpty) return parsed;
      } else if (tables.isNotEmpty) {
        // Intentar con la primera tabla disponible
        print('Usando primera tabla disponible como fallback.');
        final parsed = _parseTable(tables.first);
        if (parsed.isNotEmpty) return parsed;
      }

      // ── Estrategia 2: buscar divs / tarjetas con clase "reserva" o similar ──
      print('No se encontró tabla útil. Intentando parseo por divs/clases...');
      final cardSelectors = ['reserva', 'card', 'item', 'fila', 'row'];
      for (final cls in cardSelectors) {
        final cards = document.querySelectorAll('.$cls');
        if (cards.isNotEmpty) {
          print('Encontrados ${cards.length} elementos con clase ".$cls"');
          for (final card in cards) {
            print('Card HTML: ${card.outerHtml}');
          }
          break;
        }
      }

      // ── Estrategia 3: volcar todos los textos visibles para diagnóstico ──
      final allText = document.body?.text ?? '';
      print('Texto visible completo (primeros 800 chars): ${allText.length > 800 ? allText.substring(0, 800) : allText}');

    } catch (e) {
      print('Error en _parseHtml: $e');
    }

    return reservas;
  }

  List<Reserva> _parseTable(Element table) {
    final List<Reserva> reservas = [];

    final rows = table.getElementsByTagName('tr');
    if (rows.length <= 1) {
      print('La tabla tiene ${rows.length} filas — sin datos.');
      return reservas;
    }

    // Analizar cabeceras
    final headerRow = rows.first;
    final headers = headerRow.getElementsByTagName('th').isNotEmpty
        ? headerRow.getElementsByTagName('th')
        : headerRow.getElementsByTagName('td');

    print('Cabeceras encontradas: ${headers.map((h) => h.text.trim()).toList()}');

    int colId = -1, colFecha = -1, colHora = -1, colPersonas = -1, colEstado = -1;

    for (int i = 0; i < headers.length; i++) {
      final h = headers[i].text.toLowerCase().trim();
      if (h.contains('id') || h.contains('#') || h.contains('reserva')) colId = i;
      if (h.contains('fecha')) colFecha = i;
      if (h.contains('hora')) colHora = i;
      if (h.contains('persona') || h.contains('persona')) colPersonas = i;
      if (h.contains('estado') || h.contains('activ')) colEstado = i;
    }

    // Valores por defecto si no se detectaron cabeceras
    if (colId == -1) colId = 0;
    if (colFecha == -1) colFecha = 1;
    if (colHora == -1) colHora = 2;
    if (colPersonas == -1) colPersonas = 3;
    if (colEstado == -1) colEstado = 4;

    print('Índices de columnas → id:$colId fecha:$colFecha hora:$colHora personas:$colPersonas estado:$colEstado');

    // Iterar filas de datos (omitir cabecera)
    for (int i = 1; i < rows.length; i++) {
      final cells = rows[i].getElementsByTagName('td');
      if (cells.isEmpty) continue;

      print('Fila $i — celdas: ${cells.map((c) => c.text.trim()).toList()}');

      String safeCell(int col) =>
          (col >= 0 && col < cells.length) ? cells[col].text.trim() : '';

      reservas.add(Reserva(
        idReserva: safeCell(colId),
        fecha: safeCell(colFecha),
        hora: safeCell(colHora),
        numPersonas: safeCell(colPersonas),
        estado: safeCell(colEstado),
      ));
    }

    return reservas;
  }
}

// ── Clase de resultado tipado ──────────────────────────────────────────────────
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
