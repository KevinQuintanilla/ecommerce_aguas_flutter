import 'package:flutter/foundation.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';

class AdminProvider with ChangeNotifier {
  final PedidoService _pedidoService = PedidoService();

  List<Pedido> _todosLosPedidos = [];
  bool _cargando = false;
  String _error = '';

  List<Pedido> get todosLosPedidos => _todosLosPedidos;
  bool get cargando => _cargando;
  String get error => _error;

  /// Carga TODOS los pedidos de la base de datos.
  Future<void> cargarTodosLosPedidos() async {
    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      _todosLosPedidos = await _pedidoService.obtenerTodosLosPedidos();
      _error = '';
    } catch (e) {
      _error = 'Error al cargar todos los pedidos: $e';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Actualiza el estado de un pedido y recarga la lista.
  Future<bool> actualizarEstadoPedido(int pedidoId, int estadoId) async {
    _cargando = true;
    notifyListeners();
    try {
      final success = await _pedidoService.actualizarEstadoPedido(pedidoId, estadoId);
      if (success) {
        // Si se actualiza, recargamos la lista para que se refleje
        await cargarTodosLosPedidos();
      }
      return success;
    } catch (e) {
      _error = 'Error al actualizar el estado: $e';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }
}