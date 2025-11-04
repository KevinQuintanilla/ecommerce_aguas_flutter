class Categoria {
  final int categoriaId;
  final String nombre;
  final String? descripcion;
  final int? categoriaPadreId;
  final bool activa;

  Categoria({
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    this.categoriaPadreId,
    required this.activa,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      categoriaId: json['categoria_id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      categoriaPadreId: json['categoria_padre_id'],
      activa: json['activa'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoria_id': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria_padre_id': categoriaPadreId,
      'activa': activa ? 1 : 0,
    };
  }
}