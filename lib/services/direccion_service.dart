import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/direccion_envio.dart'; 
import '../utils/constants.dart';

class DireccionService {
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  // static const String baseUrl = 'http://localhost:3000/api';
  static const String baseUrl = kApiBaseUrl + '/api';


  // Obtener direcciones por clienteId
  Future<List<DireccionEnvio>> obtenerDirecciones(int clienteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientes/$clienteId/direcciones'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DireccionEnvio.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar direcciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Agregar nueva dirección
  Future<DireccionEnvio> agregarDireccion(Map<String, dynamic> direccionData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/direcciones'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(direccionData),
      );

      if (response.statusCode == 201) {
        return DireccionEnvio.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al agregar dirección: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar dirección
  Future<bool> actualizarDireccion(int direccionId, Map<String, dynamic> direccionData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/direcciones/$direccionId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(direccionData),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar dirección
  Future<bool> eliminarDireccion(int direccionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/direcciones/$direccionId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}