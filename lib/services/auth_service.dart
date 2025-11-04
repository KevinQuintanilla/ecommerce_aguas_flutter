import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../utils/constants.dart';

class AuthService {
  // static const String baseUrl = 'http://10.0.2.2:3000/api/auth';
  // static const String baseUrl = 'http://localhost:3000/api/auth';
  static const String baseUrl = '$kApiBaseUrl/api/auth';


  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'usuario': Usuario.fromJson(data['usuario'])};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    String? telefono,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'nombre': nombre,
          'apellido': apellido,
          'telefono': telefono,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'usuario': Usuario.fromJson(data['usuario'])};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}