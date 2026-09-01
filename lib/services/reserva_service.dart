import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../config/api_config.dart';
import '../models/reserva.dart';
import 'auth_service.dart';
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

      // Detectar si el backend redirigió al formulario de login (sesión expirada)
      final doc = html_parser.parse(response.body);
      final hayFormLogin = doc.querySelector('form[action*="Iniciar"]') != null;
      final bodyLower = response.body.toLowerCase();

      if (hayFormLogin ||
          (bodyLower.contains('inicio de sesión') &&
              bodyLower.contains('placeholder'))) {
        print('WARN: La respuesta es la página de Login — sesión no activa.');
        return ReservaResult.sessionExpired();
      }

      if (response.statusCode >= 200 && response.statusCode < 400) {
        // Log de las primeras 600 chars para diagnóstico real
        final preview = response.body.length > 600
            ? response.body.substring(0, 600)
            : response.body;
        print('HTML preview (600 chars): $preview');

        // ── Intentar extraer nombre del usuario del HTML autenticado ──────────
        // Esta es la ÚNICA página autenticada disponible — el JSP puede mostrar
        // el nombre del usuario en la barra de navegación o en el cuerpo.
        _extraerYGuardarNombre(doc, response.body);

        final reservas = _parseHtml(doc);
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

  /// Extrae el nombre del usuario del HTML autenticado de /ReservaUsuario
  /// y lo guarda en el singleton de AuthService.
  void _extraerYGuardarNombre(dynamic doc, String rawHtml) {
    // Solo sobreescribe si aún no tenemos nombre
    if (AuthService().nombreUsuario != null &&
        AuthService().nombreUsuario!.isNotEmpty) return;

    // Selectores que suelen usarse en JSP para mostrar el usuario autenticado
    final selectores = [
      'span.usuario',
      'span.nombre',
      'span.nombre-usuario',
      '.nombre-usuario',
      '#nombreUsuario',
      '#usuarioLogueado',
      'p.usuario',
      'li.usuario',
      'a.usuario',
    ];

    for (final sel in selectores) {
      final el = doc.querySelector(sel);
      if (el != null) {
        final texto = el.text.trim();
        if (texto.isNotEmpty && texto.length < 60) {
          print('[NOMBRE] Encontrado con selector "$sel": $texto');
          AuthService().setNombreUsuario(texto);
          return;
        }
      }
    }

    // Buscar con regex en el HTML bruto
    final patterns = [
      RegExp(r'hola[,:\s]+([A-Za-záéíóúÁÉÍÓÚñÑ\s]{2,40})', caseSensitive: false),
      RegExp(r'bienvenido[/a]*[,:\s]+([A-Za-záéíóúÁÉÍÓÚñÑ\s]{2,40})', caseSensitive: false),
    ];

    for (final regex in patterns) {
      final match = regex.firstMatch(rawHtml);
      if (match != null) {
        final nombre = match.group(1)?.trim().split(RegExp(r'[<!\n\r]')).first.trim();
        if (nombre != null && nombre.isNotEmpty) {
          print('[NOMBRE] Encontrado por regex: $nombre');
          AuthService().setNombreUsuario(nombre);
          return;
        }
      }
    }

    print('[NOMBRE] No se encontró el nombre en el HTML de /ReservaUsuario.');
    print('[NOMBRE] El JSP no parece incluir el nombre del usuario en el HTML renderizado.');
  }

  List<Reserva> _parseHtml(Document document) {
    final List<Reserva> reservas = [];

    try {
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
