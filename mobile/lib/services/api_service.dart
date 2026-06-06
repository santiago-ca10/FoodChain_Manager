import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/tercero_model.dart';
import '../models/producto_model.dart';
import '../models/movimiento_model.dart';

class ApiService {
  final String baseUrl = AppConfig.baseUrl;

  // ── TERCEROS ───────────────────────────────────────────────

  Future<List<Tercero>> getTerceros() async {
    final response = await http.get(Uri.parse('$baseUrl/terceros'));
    if (response.statusCode == 200) {
      final List body = jsonDecode(response.body);
      return body.map((item) => Tercero.fromJson(item)).toList();
    }
    throw Exception('Error al cargar terceros: ${response.statusCode}');
  }

  Future<Tercero> crearTercero(Map<String, dynamic> datos) async {
    final response = await http.post(
      Uri.parse('$baseUrl/terceros'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (response.statusCode == 201) {
      return Tercero.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear tercero: ${response.statusCode}');
  }

  Future<void> eliminarTercero(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/terceros/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar tercero: ${response.statusCode}');
    }
  }

  // ── PRODUCTOS ──────────────────────────────────────────────

  Future<List<Producto>> getProductos() async {
    final response = await http.get(Uri.parse('$baseUrl/productos'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Producto.fromJson(e)).toList();
    }
    throw Exception('Error al cargar productos: ${response.statusCode}');
  }

  Future<Producto> createProducto(Producto producto) async {
    final response = await http.post(
      Uri.parse('$baseUrl/productos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producto.toJson()),
    );
    if (response.statusCode == 201) {
      return Producto.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear producto: ${response.statusCode}');
  }

  Future<Producto> updateProducto(String id, Producto producto) async {
    final response = await http.put(
      Uri.parse('$baseUrl/productos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producto.toJson()),
    );
    if (response.statusCode == 200) {
      return Producto.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al actualizar producto: ${response.statusCode}');
  }

  Future<void> deleteProducto(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/productos/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar producto: ${response.statusCode}');
    }
  }

  // ── MOVIMIENTOS ────────────────────────────────────────────

  Future<List<Movimiento>> getMovimientos() async {
    final response = await http.get(Uri.parse('$baseUrl/movimientos'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Movimiento.fromJson(e)).toList();
    }
    throw Exception('Error al cargar movimientos: ${response.statusCode}');
  }

  Future<Movimiento> registrarMovimiento(Movimiento movimiento) async {
    final response = await http.post(
      Uri.parse('$baseUrl/movimientos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(movimiento.toJson()),
    );
    if (response.statusCode == 201) {
      return Movimiento.fromJson(jsonDecode(response.body));
    }
    final body = jsonDecode(response.body);
    throw Exception(body['error'] ?? 'Error al registrar movimiento');
  }

  Future<void> deleteMovimiento(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/movimientos/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar movimiento: ${response.statusCode}');
    }
  }
}
