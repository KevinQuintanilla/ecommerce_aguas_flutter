import 'direccion_envio.dart';
class Pedido {
  final int pedidoId;
  final int clienteId;
  final int direccionEnvioId;
  final int metodoPagoId;
  final int metodoEnvioId;
  final int estadoPedidoId;
  final DateTime fechaPedido;
  final DateTime? fechaEntregaEstimada;
  final DateTime? fechaEntregaReal;
  final double subtotal;
  final double impuestos;
  final double total;
  final String? codigoSeguimiento;
  final String? notas;
  final String? estadoNombre;
  final String? metodoPagoNombre;
  final String? metodoEnvioNombre;
  final List<ArticuloPedido> articulos;
  final DireccionEnvio? direccionEnvio;

  Pedido({
    required this.pedidoId,
    required this.clienteId,
    required this.direccionEnvioId,
    required this.metodoPagoId,
    required this.metodoEnvioId,
    required this.estadoPedidoId,
    required this.fechaPedido,
    this.fechaEntregaEstimada,
    this.fechaEntregaReal,
    required this.subtotal,
    required this.impuestos,
    required this.total,
    this.codigoSeguimiento,
    this.notas,
    this.estadoNombre,
    this.metodoPagoNombre,
    this.metodoEnvioNombre,
    required this.articulos,
    this.direccionEnvio,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      pedidoId: json['pedido_id'] ?? 0,
      clienteId: json['cliente_id'] ?? 0,
      direccionEnvioId: json['direccion_envio_id'] ?? 0,
      metodoPagoId: json['metodo_pago_id'] ?? 0,
      metodoEnvioId: json['metodo_envio_id'] ?? 0,
      estadoPedidoId: json['estado_pedido_id'] ?? 0,
      fechaPedido: DateTime.parse(json['fecha_pedido'] ?? DateTime.now().toString()),
      fechaEntregaEstimada: json['fecha_entrega_estimada'] != null 
          ? DateTime.parse(json['fecha_entrega_estimada'])
          : null,
      fechaEntregaReal: json['fecha_entrega_real'] != null 
          ? DateTime.parse(json['fecha_entrega_real'])
          : null,
      subtotal: double.parse((json['subtotal'] ?? '0').toString()),
      impuestos: double.parse((json['impuestos'] ?? '0').toString()),
      total: double.parse((json['total'] ?? '0').toString()),
      codigoSeguimiento: json['codigo_seguimiento'],
      notas: json['notas'],
      estadoNombre: json['estado_nombre'],
      metodoPagoNombre: json['metodo_pago_nombre'],
      metodoEnvioNombre: json['metodo_envio_nombre'],
      articulos: (json['articulos'] as List<dynamic>? ?? [])
          .map((articulo) => ArticuloPedido.fromJson(articulo))
          .toList(),
      direccionEnvio: json['calle'] != null ? DireccionEnvio.fromJson(json) : null,
    );
  }

  String get estadoDisplay {
    switch (estadoPedidoId) {
      case 1: return 'Recibido';
      case 2: return 'Confirmado';
      case 3: return 'En camino';
      case 4: return 'Entregado';
      case 5: return 'Cancelado';
      default: return 'Desconocido';
    }
  }
}

class ArticuloPedido {
  final int articuloPedidoId;
  final int pedidoId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? productoNombre;
  final String? imagenUrl;

  ArticuloPedido({
    required this.articuloPedidoId,
    required this.pedidoId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.productoNombre,
    this.imagenUrl,
  });

  factory ArticuloPedido.fromJson(Map<String, dynamic> json) {
    return ArticuloPedido(
      articuloPedidoId: json['articulo_pedido_id'] ?? 0,
      pedidoId: json['pedido_id'] ?? 0,
      productoId: json['producto_id'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
      precioUnitario: double.parse((json['precio_unitario'] ?? '0').toString()),
      subtotal: double.parse((json['subtotal'] ?? '0').toString()),
      productoNombre: json['producto_nombre'],
      imagenUrl: json['imagen_url'],
    );
  }
}