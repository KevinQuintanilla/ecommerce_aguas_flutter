// lib/providers/pedido_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/pedido.dart';
import '../models/metodo_pago.dart';
import '../services/pedido_service.dart';
import '../utils/constants.dart'; // <--- ¡AÑADIDO!

class PedidoProvider with ChangeNotifier {
  final PedidoService _pedidoService = PedidoService();
  
  // ¡CAMBIADO! Ahora usa tu constante kApiBaseUrl
  final String _baseUrl = '${kApiBaseUrl}/api'; 

  List<Pedido> _pedidos = [];
  List<MetodoPago> _metodosPago = [];
  List<MetodoEnvio> _metodosEnvio = [];
  bool _cargando = false;
  String _error = '';

  List<Pedido> get pedidos => _pedidos;
  List<MetodoPago> get metodosPago => _metodosPago;
  List<MetodoEnvio> get metodosEnvio => _metodosEnvio;
  bool get cargando => _cargando;
  String get error => _error;

  // Cargar pedidos del cliente
  Future<void> cargarPedidos(int clienteId) async {
    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      _pedidos = await _pedidoService.obtenerPedidosCliente(clienteId);
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _cargando = false;
      _error = 'Error al cargar pedidos: $e';
      notifyListeners();
    }
  }

  // Cargar métodos de pago
  Future<void> cargarMetodosPago() async {
    try {
      _metodosPago = await _pedidoService.obtenerMetodosPago();
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar métodos de pago: $e';
      notifyListeners();
    }
  }

  // Cargar métodos de envío
  Future<void> cargarMetodosEnvio() async {
    try {
      _metodosEnvio = await _pedidoService.obtenerMetodosEnvio();
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar métodos de envío: $e';
      notifyListeners();
    }
  }

  // Crear nuevo pedido
  Future<Map<String, dynamic>> crearPedido({
    required int clienteId,
    required int direccionEnvioId,
    required int metodoPagoId,
    required int metodoEnvioId,
    required List<Map<String, dynamic>> items,
    String? notas,
  }) async {
    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      // Asumimos que _pedidoService también usa la constante, 
      // si no, habría que pasarle el _baseUrl
      final resultado = await _pedidoService.crearPedido(
        clienteId: clienteId,
        direccionEnvioId: direccionEnvioId,
        metodoPagoId: metodoPagoId,
        metodoEnvioId: metodoEnvioId,
        items: items,
        notas: notas,
      );

      _cargando = false;
      
      if (resultado['success'] == true) {
        _pedidos.insert(0, resultado['pedido'] as Pedido);
        notifyListeners();
      }

      return resultado;
    } catch (e) {
      _cargando = false;
      _error = 'Error al crear pedido: $e';
      notifyListeners();
      return {'success': false, 'error': _error};
    }
  }

  // Función de pago de Stripe (sin cambios, solo usa la nueva _baseUrl)
  Future<Map<String, dynamic>> iniciarPagoStripe(int pedidoId) async {
    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/pagos/crear-sesion-stripe');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'pedido_id': pedidoId}),
      );

      _cargando = false;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['url'] != null) {
          return {'success': true, 'url': data['url']};
        } else {
          return {'success': false, 'error': 'No se recibió la URL de pago'};
        }
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'error': data['error'] ?? 'Error del servidor'};
      }
    } catch (e) {
      _cargando = false;
      _error = 'Error al iniciar pago: $e';
      notifyListeners();
      return {'success': false, 'error': _error};
    }
  }

  // Obtener pedido por ID
  Future<Pedido?> obtenerPedido(int pedidoId) async {
    try {
      return await _pedidoService.obtenerPedido(pedidoId);
    } catch (e) {
      _error = 'Error al obtener pedido: $e';
      notifyListeners();
      return null;
    }
  }

  void limpiarError() {
    _error = '';
    notifyListeners();
  }
}