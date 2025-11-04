import 'package:flutter/foundation.dart';
import '../models/categoria.dart';
import '../services/producto_service.dart';

class CategoriaProvider with ChangeNotifier {
  final ProductoService _productoService = ProductoService();

  List<Categoria> _categorias = [];
  int? _categoriaSeleccionadaId; // null = "Todas"
  bool _cargando = false;
  String _error = '';

  List<Categoria> get categorias => _categorias;
  int? get categoriaSeleccionadaId => _categoriaSeleccionadaId;
  bool get cargando => _cargando;
  String get error => _error;

  // Filtramos solo las categorías que queremos mostrar como filtros
  // (Nivel 1 y 2, ej: "Agua", "Merchandise", "Agua PET", "Playeras")
  List<Categoria> get categoriasParaFiltro {
    return _categorias.where((c) => c.categoriaPadreId == null || c.categoriaPadreId! <= 3).toList();
  }

  CategoriaProvider() {
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    _cargando = true;
    notifyListeners();
    try {
      _categorias = await _productoService.obtenerCategorias();
      _error = '';
    } catch (e) {
      _error = 'Error al cargar categorías: $e';
    }
    _cargando = false;
    notifyListeners();
  }

  void seleccionarCategoria(int? categoriaId) {
    _categoriaSeleccionadaId = categoriaId;
    notifyListeners(); // Notifica a la pantalla de productos que debe recargar
  }
}