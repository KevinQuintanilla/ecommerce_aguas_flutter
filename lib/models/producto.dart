import 'resena.dart'; 

class Producto {
  final int productoId;
  final int categoriaId;
  final String nombre;
  final String? descripcion;
  final double precioActual;
  final String? sku;
  final String? imagenUrl;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
  final String? categoriaNombre;
  final List<Resena> resenas; 

  Producto({
    required this.productoId,
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    required this.precioActual,
    this.sku,
    this.imagenUrl,
    required this.activo,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.categoriaNombre,
    this.resenas = const [], 
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    var listaResenasJson = json['resenas'] as List<dynamic>? ?? [];
    List<Resena> listaResenas = listaResenasJson
        .map((i) => Resena.fromJson(i))
        .toList();

    return Producto(
      productoId: json['producto_id'] ?? 0,
      categoriaId: json['categoria_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      precioActual: double.parse((json['precio_actual'] ?? '0').toString()),
      sku: json['sku'],
      imagenUrl: json['imagen_url'],
      activo: (json['activo'] ?? 0) == 1,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] ?? DateTime.now().toString()),
      fechaActualizacion: DateTime.parse(json['fecha_actualizacion'] ?? DateTime.now().toString()),
      categoriaNombre: json['categoria_nombre'],
      resenas: listaResenas, 
    );
  }
}