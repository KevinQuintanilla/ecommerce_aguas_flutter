class Resena { 
  final int resenaId; 
  final int productoId;
  final int clienteId;
  final int puntuacion;
  final String? comentario;
  final DateTime fechaResena; 
  final String? clienteNombre;

  Resena({
    required this.resenaId, 
    required this.productoId,
    required this.clienteId,
    required this.puntuacion,
    this.comentario,
    required this.fechaResena, 
    this.clienteNombre,
  });

  factory Resena.fromJson(Map<String, dynamic> json) {
    return Resena(
      resenaId: json['resena_id'] ?? 0, 
      productoId: json['producto_id'] ?? 0,
      clienteId: json['cliente_id'] ?? 0,
      puntuacion: json['puntuacion'] ?? 0,
      comentario: json['comentario'],
      fechaResena: DateTime.parse(json['fecha_resena'] ?? DateTime.now().toString()), 
      clienteNombre: json['cliente_nombre'] ?? 'Anónimo',
    );
  }
}