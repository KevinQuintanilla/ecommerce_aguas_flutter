class Usuario {
  final int usuarioId;
  final String email;
  final String? nombre;
  final String? apellido;
  final String? telefono;
  final String tipoUsuario;
  final int? clienteId;

  Usuario({
    required this.usuarioId,
    required this.email,
    this.nombre,
    this.apellido,
    this.telefono,
    required this.tipoUsuario,
    this.clienteId,
  });

  String get nombreCompleto => '$nombre $apellido';

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'tipo_usuario': tipoUsuario,
      'cliente_id': clienteId,
      'nombre_completo': nombreCompleto,
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      usuarioId: json['usuario_id'] ?? 0,
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      telefono: json['telefono'] ?? '',
      tipoUsuario: json['tipo_usuario'] ?? 'cliente',
      clienteId: json['cliente_id'],
    );
  }
}