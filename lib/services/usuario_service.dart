import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart'; 
import '../models/usuario.dart'; 

class UsuarioService {
  final String _baseUrl = '$kApiBaseUrl/api';

  /// Actualiza los datos personales del cliente (nombre, apellido, teléfono)
  /// Llama al endpoint: PUT /api/clientes/:id
  Future<Map<String, dynamic>> actualizarPerfil(int clienteId, String nombre, String apellido, String? telefono) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/clientes/$clienteId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'apellido': apellido,
          'telefono': telefono,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'usuario': Usuario.fromJson(data['usuario'])};
      } else {
        return {'success': false, 'error': data['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Cambia la contraseña del usuario
  /// Llama al endpoint: PUT /api/usuarios/:id/password
  Future<Map<String, dynamic>> cambiarPassword(int usuarioId, String currentPassword, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/usuarios/$usuarioId/password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        // Devuelve el error (ej. "La contraseña actual es incorrecta")
        return {'success': false, 'error': data['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}