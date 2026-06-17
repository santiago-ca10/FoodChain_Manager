import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/tercero_model.dart';
import '../models/producto_model.dart';
import '../models/movimiento_model.dart';
import 'auth_service.dart';
import 'local_database.dart';
import 'sync_service.dart';

class ApiService {
  final String baseUrl = AppConfig.baseUrl;
  final _local = LocalDatabase();
  final _sync = SyncService();

  Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── TERCEROS ───────────────────────────────────────────────

  Future<List<Tercero>> getTerceros() async {
    if (await _sync.hayConexion()) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/terceros'),
          headers: await _headers(),
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          final lista = data.map((e) => Tercero.fromJson(e)).toList();
          await _local.cacheTerceros(lista);
          return lista;
        }
      } catch (_) {}
    }
    return _local.getTerceros();
  }

  Future<Tercero> crearTercero(Map<String, dynamic> datos) async {
    if (await _sync.hayConexion()) {
      final response = await http.post(
        Uri.parse('$baseUrl/terceros'),
        headers: await _headers(),
        body: jsonEncode(datos),
      );
      if (response.statusCode == 201) {
        final t = Tercero.fromJson(jsonDecode(response.body));
        await _local.cacheTerceros(await getTerceros());
        return t;
      }
      throw Exception('Error al crear tercero: ${response.statusCode}');
    } else {
      await _local.encolarOperacion(
        metodo: 'POST',
        endpoint: '/terceros',
        body: datos,
      );
      // Optimistic local insert
      final temp = Tercero(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        nombre: datos['nombre'] ?? '',
        tipo: datos['tipo'] ?? '',
        telefono: datos['telefono'],
        direccion: datos['direccion'],
      );
      final lista = await _local.getTerceros();
      lista.add(temp);
      await _local.cacheTerceros(lista);
      return temp;
    }
  }

  Future<void> eliminarTercero(String id) async {
    if (await _sync.hayConexion()) {
      final response = await http.delete(
        Uri.parse('$baseUrl/terceros/$id'),
        headers: await _headers(),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar tercero: ${response.statusCode}');
      }
    } else {
      await _local.encolarOperacion(
        metodo: 'DELETE',
        endpoint: '/terceros/$id',
      );
    }
    final lista = await _local.getTerceros();
    lista.removeWhere((t) => t.id == id);
    await _local.cacheTerceros(lista);
  }

  // ── PRODUCTOS ──────────────────────────────────────────────

  Future<List<Producto>> getProductos() async {
    if (await _sync.hayConexion()) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/productos'),
          headers: await _headers(),
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          final lista = data.map((e) => Producto.fromJson(e)).toList();
          await _local.cacheProductos(lista);
          return lista;
        }
      } catch (_) {}
    }
    return _local.getProductos();
  }

  Future<Producto> createProducto(Producto producto) async {
    if (await _sync.hayConexion()) {
      final response = await http.post(
        Uri.parse('$baseUrl/productos'),
        headers: await _headers(),
        body: jsonEncode(producto.toJson()),
      );
      if (response.statusCode == 201) {
        final p = Producto.fromJson(jsonDecode(response.body));
        await _local.cacheProductos(await getProductos());
        return p;
      }
      throw Exception('Error al crear producto: ${response.statusCode}');
    } else {
      await _local.encolarOperacion(
        metodo: 'POST',
        endpoint: '/productos',
        body: producto.toJson(),
      );
      final temp = Producto(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        nombre: producto.nombre,
        categoria: producto.categoria,
        precio: producto.precio,
        stock: producto.stock,
        unidad: producto.unidad,
      );
      final lista = await _local.getProductos();
      lista.add(temp);
      await _local.cacheProductos(lista);
      return temp;
    }
  }

  Future<Producto> updateProducto(String id, Producto producto) async {
    if (await _sync.hayConexion()) {
      final response = await http.put(
        Uri.parse('$baseUrl/productos/$id'),
        headers: await _headers(),
        body: jsonEncode(producto.toJson()),
      );
      if (response.statusCode == 200) {
        final p = Producto.fromJson(jsonDecode(response.body));
        await _local.updateProductoLocal(p);
        return p;
      }
      throw Exception('Error al actualizar producto: ${response.statusCode}');
    } else {
      await _local.encolarOperacion(
        metodo: 'PUT',
        endpoint: '/productos/$id',
        body: producto.toJson(),
      );
      await _local.updateProductoLocal(producto);
      return producto;
    }
  }

  Future<void> deleteProducto(String id) async {
    if (await _sync.hayConexion()) {
      final response = await http.delete(
        Uri.parse('$baseUrl/productos/$id'),
        headers: await _headers(),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar producto: ${response.statusCode}');
      }
    } else {
      await _local.encolarOperacion(
        metodo: 'DELETE',
        endpoint: '/productos/$id',
      );
    }
    await _local.deleteProductoLocal(id);
  }

  // ── MOVIMIENTOS ────────────────────────────────────────────

  Future<List<Movimiento>> getMovimientos() async {
    if (await _sync.hayConexion()) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/movimientos'),
          headers: await _headers(),
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          final lista = data.map((e) => Movimiento.fromJson(e)).toList();
          await _local.cacheMovimientos(lista);
          return lista;
        }
      } catch (_) {}
    }
    return _local.getMovimientos();
  }

  Future<Movimiento> registrarMovimiento(Movimiento movimiento) async {
    if (await _sync.hayConexion()) {
      final response = await http.post(
        Uri.parse('$baseUrl/movimientos'),
        headers: await _headers(),
        body: jsonEncode(movimiento.toJson()),
      );
      if (response.statusCode == 201) {
        final m = Movimiento.fromJson(jsonDecode(response.body));
        await _local.cacheMovimientos(await getMovimientos());
        return m;
      }
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Error al registrar movimiento');
    } else {
      await _local.encolarOperacion(
        metodo: 'POST',
        endpoint: '/movimientos',
        body: movimiento.toJson(),
      );
      final temp = Movimiento(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        tipo: movimiento.tipo,
        cantidad: movimiento.cantidad,
        precioUnitario: movimiento.precioUnitario,
        total: movimiento.totalCalculado,
        productoId: movimiento.productoId,
        productoNombre: movimiento.productoNombre,
        terceroId: movimiento.terceroId,
        terceroNombre: movimiento.terceroNombre,
        fecha: DateTime.now(),
      );
      final lista = await _local.getMovimientos();
      lista.insert(0, temp);
      await _local.cacheMovimientos(lista);
      return temp;
    }
  }

  Future<void> deleteMovimiento(String id) async {
    if (id.startsWith('temp_')) {
      // Era un registro temporal, solo eliminar de cola
      await _local.deleteMovimientoLocal(id);
      return;
    }
    if (await _sync.hayConexion()) {
      final response = await http.delete(
        Uri.parse('$baseUrl/movimientos/$id'),
        headers: await _headers(),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar movimiento: ${response.statusCode}');
      }
    } else {
      await _local.encolarOperacion(
        metodo: 'DELETE',
        endpoint: '/movimientos/$id',
      );
    }
    await _local.deleteMovimientoLocal(id);
  }
}
