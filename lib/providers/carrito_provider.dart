import 'package:flutter/foundation.dart';
import '../models/carrito_item.dart';
import '../models/producto.dart';

class CarritoProvider with ChangeNotifier {
  final List<CarritoItem> _items = [];

  List<CarritoItem> get items => _items;
  
  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.cantidad);
  }
  
  double get totalPrecio {
    return _items.fold(0.0, (sum, item) => sum + item.subtotal);
  }
  
  bool get estaVacio => _items.isEmpty;

  // Agregar producto al carrito
  void agregarProducto(Producto producto, [int cantidad = 1]) {
    final existingIndex = _items.indexWhere((item) => item.productoId == producto.productoId);
    
    if (existingIndex >= 0) {
      // Si ya existe, incrementar cantidad
      _items[existingIndex] = _items[existingIndex].copyWith(
        cantidad: _items[existingIndex].cantidad + cantidad,
      );
    } else {
      // Si no existe, agregar nuevo item
      _items.add(CarritoItem(
        productoId: producto.productoId,
        nombre: producto.nombre,
        imagenUrl: producto.imagenUrl,
        precio: producto.precioActual,
        cantidad: cantidad,
        sku: producto.sku,
      ));
    }
    
    notifyListeners();
  }

  // Remover producto del carrito
  void removerProducto(int productoId) {
    _items.removeWhere((item) => item.productoId == productoId);
    notifyListeners();
  }

  // Actualizar cantidad de un producto
  void actualizarCantidad(int productoId, int nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      removerProducto(productoId);
      return;
    }
    
    final index = _items.indexWhere((item) => item.productoId == productoId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(cantidad: nuevaCantidad);
      notifyListeners();
    }
  }

  // Incrementar cantidad
  void incrementarCantidad(int productoId) {
    final index = _items.indexWhere((item) => item.productoId == productoId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        cantidad: _items[index].cantidad + 1,
      );
      notifyListeners();
    }
  }

  // Decrementar cantidad
  void decrementarCantidad(int productoId) {
    final index = _items.indexWhere((item) => item.productoId == productoId);
    if (index >= 0) {
      if (_items[index].cantidad > 1) {
        _items[index] = _items[index].copyWith(
          cantidad: _items[index].cantidad - 1,
        );
      } else {
        removerProducto(productoId);
      }
      notifyListeners();
    }
  }

  // Limpiar carrito
  void limpiarCarrito() {
    _items.clear();
    notifyListeners();
  }

  // Verificar si un producto está en el carrito
  bool estaEnCarrito(int productoId) {
    return _items.any((item) => item.productoId == productoId);
  }

  // Obtener cantidad de un producto específico
  int cantidadDeProducto(int productoId) {
    final item = _items.firstWhere(
      (item) => item.productoId == productoId,
      orElse: () => CarritoItem(
        productoId: -1,
        nombre: '',
        precio: 0,
        cantidad: 0,
      ),
    );
    return item.cantidad;
  }
}