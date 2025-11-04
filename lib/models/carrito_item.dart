class CarritoItem {
  final int productoId;
  final String nombre;
  final String? imagenUrl;
  final double precio;
  int cantidad;
  final String? sku;

  CarritoItem({
    required this.productoId,
    required this.nombre,
    this.imagenUrl,
    required this.precio,
    required this.cantidad,
    this.sku,
  });

  double get subtotal => precio * cantidad;

  CarritoItem copyWith({
    int? productoId,
    String? nombre,
    String? imagenUrl,
    double? precio,
    int? cantidad,
    String? sku,
  }) {
    return CarritoItem(
      productoId: productoId ?? this.productoId,
      nombre: nombre ?? this.nombre,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
      sku: sku ?? this.sku,
    );
  }
}