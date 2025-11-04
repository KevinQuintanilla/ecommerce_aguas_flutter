import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';

class AuthProvider with ChangeNotifier {
  Usuario? _usuario;
  bool _cargando = false;
  String _error = '';

  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  String get error => _error;
  bool get estaAutenticado => _usuario != null;

  final AuthService _authService = AuthService();
  final UsuarioService _usuarioService = UsuarioService();

  Future<bool> login(String email, String password) async {
    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      
      _cargando = false;
      
      if (result['success'] == true) {
        _usuario = result['usuario'] as Usuario;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Error desconocido';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cargando = false;
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    String? telefono,
  }) async {
    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
      );
      
      _cargando = false;
      
      if (result['success'] == true) {
        _usuario = result['usuario'] as Usuario;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Error desconocido';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cargando = false;
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _usuario = null;
    _error = '';
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // --- MÉTODO NUEVO 1: ACTUALIZAR PERFIL ---
  Future<Map<String, dynamic>> actualizarPerfil(String nombre, String apellido, String? telefono) async {
    if (_usuario == null || _usuario!.clienteId == null) {
      return {'success': false, 'error': 'Usuario no autenticado'};
    }

    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _usuarioService.actualizarPerfil(
        _usuario!.clienteId!,
        nombre,
        apellido,
        telefono,
      );
      
      _cargando = false;
      
      if (result['success'] == true) {
        // ¡Éxito! Actualizamos el usuario local
        _usuario = result['usuario'] as Usuario;
        _error = '';
      } else {
        _error = result['error'] ?? 'Error desconocido';
      }
      notifyListeners();
      return result;

    } catch (e) {
      _cargando = false;
      _error = 'Error inesperado: $e';
      notifyListeners();
      return {'success': false, 'error': _error};
    }
  }

  // --- MÉTODO NUEVO 2: CAMBIAR CONTRASEÑA ---
  Future<Map<String, dynamic>> cambiarPassword(String currentPassword, String newPassword) async {
    if (_usuario == null) {
      return {'success': false, 'error': 'Usuario no autenticado'};
    }

    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _usuarioService.cambiarPassword(
        _usuario!.usuarioId,
        currentPassword,
        newPassword,
      );
      
      _cargando = false;
      
      if (result['success'] == false) {
        _error = result['error'] ?? 'Error desconocido';
      } else {
        _error = '';
      }
      notifyListeners();
      return result;

    } catch (e) {
      _cargando = false;
      _error = 'Error inesperado: $e';
      notifyListeners();
      return {'success': false, 'error': _error};
    }
  }
}