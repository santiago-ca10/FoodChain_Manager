import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/tercero_model.dart';

class ApiService {
  final String baseUrl = AppConfig.baseUrl;

  // GET — obtener todos los terceros
  Future<List<Tercero>> getTerceros() async {
    final response = await http.get(Uri.parse('$baseUrl/terceros'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Tercero.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar terceros: ${response.statusCode}');
    }
  }

  // POST — crear un tercero nuevo
  Future<Tercero> crearTercero(Map<String, dynamic> datos) async {
    final response = await http.post(
      Uri.parse('$baseUrl/terceros'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (response.statusCode == 201) {
      return Tercero.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear tercero: ${response.statusCode}');
    }
  }

  // DELETE — eliminar un tercero
  Future<void> eliminarTercero(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/terceros/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar tercero: ${response.statusCode}');
    }
  }
}
