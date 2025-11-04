import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../models/usuario.dart';
import '../providers/auth_provider.dart';
import '../services/producto_service.dart'; 
import '../utils/app_styles.dart';
import '../widgets/responsive_layout.dart'; // <-- Añadido ResponsiveLayout

class DetallePedidoScreen extends StatelessWidget { // <-- ¡ESTE ES EL DE PEDIDO!
  final Pedido pedido;

  const DetallePedidoScreen({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usuario = authProvider.usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Pedido #${pedido.pedidoId}'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
      ),
      backgroundColor: AppStyles.backgroundColor,
      body: ResponsiveLayout( // <-- Añadido ResponsiveLayout
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResumenInfo(pedido),
              const SizedBox(height: AppStyles.largePadding),
              Text(
                'Artículos del Pedido',
                style: AppStyles.headingStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppStyles.defaultPadding),
              Container(
                decoration: AppStyles.cardDecoration,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pedido.articulos.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final articulo = pedido.articulos[index];
                    return _buildArticuloItem(context, articulo, usuario);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumenInfo(Pedido pedido) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          _buildInfoItem('Estado', pedido.estadoDisplay),
          _buildInfoItem('Fecha', 
            '${pedido.fechaPedido.day}/${pedido.fechaPedido.month}/${pedido.fechaPedido.year}'),
          _buildInfoItem('Total', '\$${pedido.total.toStringAsFixed(2)}'),
          _buildInfoItem('Método de Pago', pedido.metodoPagoNombre ?? 'N/A'),
          if (pedido.direccionEnvio != null)
            _buildInfoItem('Enviado a', pedido.direccionEnvio!.direccionCompleta),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value, 
              style: AppStyles.bodyTextStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticuloItem(BuildContext context, ArticuloPedido articulo, Usuario? usuario) {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: AppStyles.cardDecoration.copyWith(
                  color: AppStyles.backgroundColor,
                  border: Border.all(color: AppStyles.borderColor)
                ),
                child: const Icon(Icons.local_drink, color: AppStyles.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      articulo.productoNombre ?? 'Producto',
                      style: AppStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${articulo.cantidad} x \$${articulo.precioUnitario.toStringAsFixed(2)}',
                      style: AppStyles.captionStyle,
                    ),
                  ],
                ),
              ),
              Text(
                '\$${articulo.subtotal.toStringAsFixed(2)}',
                style: AppStyles.subheadingStyle.copyWith(fontSize: 16),
              ),
            ],
          ),
          if (pedido.estadoPedidoId == 4) // Solo si el pedido fue "Entregado"
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.rate_review, size: 18),
                  label: const Text('Escribir reseña'),
                  style: AppStyles.secondaryButtonStyle,
                  onPressed: () {
                    if (usuario != null && usuario.clienteId != null) {
                      _mostrarDialogoResena(
                        context, 
                        articulo, 
                        usuario.clienteId!, 
                        pedido.pedidoId
                      );
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _mostrarDialogoResena(
    BuildContext context, 
    ArticuloPedido articulo, 
    int clienteId,
    int pedidoId
  ) {
    final _comentarioController = TextEditingController();
    int _puntuacion = 5;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text('Reseña para ${articulo.productoNombre}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Tu puntuación:', style: AppStyles.captionStyle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _puntuacion ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setStateInDialog(() {
                            _puntuacion = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _comentarioController,
                    decoration: AppStyles.textFieldDecoration('Tu comentario (opcional)'),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: AppStyles.primaryButtonStyle.copyWith(
                    minimumSize: MaterialStateProperty.all(Size.zero)
                  ),
                  onPressed: () async {
                    final productoService = ProductoService();
                    final resultado = await productoService.enviarResena(
                      productoId: articulo.productoId,
                      clienteId: clienteId,
                      pedidoId: pedidoId,
                      puntuacion: _puntuacion,
                      comentario: _comentarioController.text.trim(),
                    );
                    
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      if (resultado['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          AppStyles.successSnackBar('¡Gracias por tu reseña!'),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          AppStyles.errorSnackBar('Error: ${resultado['error']}'),
                        );
                      }
                    }
                  },
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}