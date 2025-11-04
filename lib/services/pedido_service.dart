import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedido.dart';
import '../models/metodo_pago.dart';
import '../utils/constants.dart';

class PedidoService {
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  // static const String baseUrl = 'http://localhost:3000/api';
  static const String baseUrl = kApiBaseUrl + '/api';


  // Crear nuevo pedido
  Future<Map<String, dynamic>> crearPedido({
    required int clienteId,
    required int direccionEnvioId,
    required int metodoPagoId,
    required int metodoEnvioId,
    required List<Map<String, dynamic>> items,
    String? notas,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pedidos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'cliente_id': clienteId,
          'direccion_envio_id': direccionEnvioId,
          'metodo_pago_id': metodoPagoId,
          'metodo_envio_id': metodoEnvioId,
          'items': items,
          'notas': notas,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'pedido': Pedido.fromJson(data['pedido']),
          'message': data['message'],
        };
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener pedidos de un cliente
  Future<List<Pedido>> obtenerPedidosCliente(int clienteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientes/$clienteId/pedidos'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pedido.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar pedidos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener pedido específico
  Future<Pedido> obtenerPedido(int pedidoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pedidos/$pedidoId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pedido.fromJson(data);
      } else {
        throw Exception('Error al obtener pedido: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener métodos de pago
  Future<List<MetodoPago>> obtenerMetodosPago() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/metodos-pago'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MetodoPago.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar métodos de pago: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener métodos de envío
  Future<List<MetodoEnvio>> obtenerMetodosEnvio() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/metodos-envio'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MetodoEnvio.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar métodos de envío: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}