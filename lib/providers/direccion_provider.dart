import 'package:flutter/foundation.dart';
import '../models/direccion_envio.dart';
import '../services/direccion_service.dart';

class DireccionProvider with ChangeNotifier {
  final DireccionService _direccionService = DireccionService();
  
  List<DireccionEnvio> _direcciones = [];
  bool _cargando = false;
  String _error = '';
  int? _ultimoClienteIdCargado;

  List<DireccionEnvio> get direcciones => _direcciones;
  bool get cargando => _cargando;
  String get error => _error;

  DireccionEnvio? get direccionEnvioPredeterminada {
    if (_direcciones.isEmpty) return null;
    return _direcciones.firstWhere(
      (d) => d.tipo == 'envío', 
      orElse: () => _direcciones.first
    );
  }

  Future<void> cargarDirecciones(int clienteId) async {
    _cargando = true;
    _error = '';
    _ultimoClienteIdCargado = clienteId; 
    notifyListeners();

    try {
      _direcciones = await _direccionService.obtenerDirecciones(clienteId);
    } catch (e) {
      _error = 'Error al cargar direcciones: $e';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> agregarDireccion(Map<String, dynamic> data) async {
    try {
      DireccionEnvio nueva = await _direccionService.agregarDireccion(data);
      _direcciones.add(nueva);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar dirección: $e';
      notifyListeners();
      return false;
    }
  }

  // Lógica de actualización
  Future<bool> actualizarDireccion(int direccionId, Map<String, dynamic> data) async {
    try {
      bool success = await _direccionService.actualizarDireccion(direccionId, data);
      if (success && _ultimoClienteIdCargado != null) {
        await cargarDirecciones(_ultimoClienteIdCargado!);
      }
      return success;
    } catch (e) {
      _error = 'Error al actualizar dirección: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarDireccion(int direccionId) async {
    try {
      await _direccionService.eliminarDireccion(direccionId);
      _direcciones.removeWhere((d) => d.direccionId == direccionId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar dirección: $e';
      notifyListeners();
      return false;
    }
  }
}