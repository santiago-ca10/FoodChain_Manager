import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tercero_model.dart';

class ApiService {
  // En el navegador usamos localhost, en celular usaremos tu IP real
  final String baseUrl = "http://localhost:3000/api";

  Future<List<Tercero>> getTerceros() async {
    final response = await http.get(Uri.parse('$baseUrl/terceros'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Tercero.fromJson(item)).toList();
    } else {
      throw Exception('Fallo al cargar terceros');
    }
  }
}