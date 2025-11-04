class DireccionEnvio {
  final int direccionId;
  final int clienteId;
  final String tipo;
  final String calle;
  final String? numeroExterior;
  final String? numeroInterior;
  final String? colonia;
  final String ciudad;
  final String estado;
  final String codigoPostal;
  final String pais;
  final String? referencias;

  DireccionEnvio({
    required this.direccionId,
    required this.clienteId,
    required this.tipo,
    required this.calle,
    this.numeroExterior,
    this.numeroInterior,
    this.colonia,
    required this.ciudad,
    required this.estado,
    required this.codigoPostal,
    this.pais = 'México',
    this.referencias,
  });

  factory DireccionEnvio.fromJson(Map<String, dynamic> json) {
    return DireccionEnvio(
      direccionId: json['direccion_id'] ?? 0,
      clienteId: json['cliente_id'] ?? 0,
      tipo: json['tipo'] ?? 'envío',
      calle: json['calle'] ?? '',
      numeroExterior: json['numero_exterior'],
      numeroInterior: json['numero_interior'],
      colonia: json['colonia'],
      ciudad: json['ciudad'] ?? '',
      estado: json['estado'] ?? '',
      codigoPostal: json['codigo_postal'] ?? '',
      pais: json['pais'] ?? 'México',
      referencias: json['referencias'],
    );
  }

  String get direccionCompleta {
    final parts = [
      '$calle',
      if (numeroExterior != null) '#$numeroExterior',
      if (numeroInterior != null) 'Int. $numeroInterior',
      if (colonia != null) 'Col. $colonia',
      '$ciudad, $estado',
      'C.P. $codigoPostal',
      pais
    ];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }
}