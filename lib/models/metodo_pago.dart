class MetodoPago {
  final int metodoPagoId;
  final String nombre;
  final String? descripcion;
  final bool activo;

  MetodoPago({
    required this.metodoPagoId,
    required this.nombre,
    this.descripcion,
    required this.activo,
  });

  factory MetodoPago.fromJson(Map<String, dynamic> json) {
    return MetodoPago(
      metodoPagoId: json['metodo_pago_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      activo: (json['activo'] ?? 0) == 1,
    );
  }
}

class MetodoEnvio {
  final int metodoEnvioId;
  final String nombre;
  final String? descripcion;
  final double costo;
  final String? tiempoEstimado;
  final bool activo;

  MetodoEnvio({
    required this.metodoEnvioId,
    required this.nombre,
    this.descripcion,
    required this.costo,
    this.tiempoEstimado,
    required this.activo,
  });

  factory MetodoEnvio.fromJson(Map<String, dynamic> json) {
    return MetodoEnvio(
      metodoEnvioId: json['metodo_envio_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      costo: double.parse((json['costo'] ?? '0').toString()),
      tiempoEstimado: json['tiempo_estimado'],
      activo: (json['activo'] ?? 0) == 1,
    );
  }
}