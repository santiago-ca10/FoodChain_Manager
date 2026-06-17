import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/local_database.dart';
import '../models/tercero_model.dart';
import '../models/producto_model.dart';
import '../models/movimiento_model.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _local = LocalDatabase();

  Future<bool> hayConexion() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Stream<bool> get conectividadStream => Connectivity()
      .onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));

  Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── SINCRONIZACIÓN DE COLA ─────────────────────────────────

  Future<void> sincronizarPendientes() async {
    if (!await hayConexion()) return;

    final pendientes = await _local.getPendientes();
    final headers = await _headers();

    for (final op in pendientes) {
      try {
        final metodo = op['metodo'] as String;
        final endpoint = op['endpoint'] as String;
        final bodyStr = op['body'] as String?;
        final body = bodyStr != null ? jsonEncode(jsonDecode(bodyStr)) : null;
        final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');

        http.Response response;
        switch (metodo) {
          case 'POST':
            response = await http.post(uri, headers: headers, body: body);
            break;
          case 'PUT':
            response = await http.put(uri, headers: headers, body: body);
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: headers);
            break;
          default:
            continue;
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          await _local.eliminarPendiente(op['id'] as int);
        }
      } catch (_) {
        // Si falla, se deja en la cola para el próximo intento
      }
    }

    // Refrescar caché después de sincronizar
    await refrescarTodo();
  }

  // ── REFRESCO DE CACHÉ ──────────────────────────────────────

  Future<void> refrescarTodo() async {
    if (!await hayConexion()) return;
    await Future.wait([
      _refrescarTerceros(),
      _refrescarProductos(),
      _refrescarMovimientos(),
    ]);
  }

  Future<void> _refrescarTerceros() async {
    try {
      final headers = await _headers();
      final res =
          await http.get(Uri.parse('${AppConfig.baseUrl}/terceros'), headers: headers);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final lista = data.map((e) => Tercero.fromJson(e)).toList();
        await _local.cacheTerceros(lista);
      }
    } catch (_) {}
  }

  Future<void> _refrescarProductos() async {
    try {
      final headers = await _headers();
      final res =
          await http.get(Uri.parse('${AppConfig.baseUrl}/productos'), headers: headers);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final lista = data.map((e) => Producto.fromJson(e)).toList();
        await _local.cacheProductos(lista);
      }
    } catch (_) {}
  }

  Future<void> _refrescarMovimientos() async {
    try {
      final headers = await _headers();
      final res = await http.get(
          Uri.parse('${AppConfig.baseUrl}/movimientos'), headers: headers);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final lista = data.map((e) => Movimiento.fromJson(e)).toList();
        await _local.cacheMovimientos(lista);
      }
    } catch (_) {}
  }
}
