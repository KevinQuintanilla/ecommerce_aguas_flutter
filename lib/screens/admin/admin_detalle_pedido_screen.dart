import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pedido.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_styles.dart';

class AdminDetallePedidoScreen extends StatefulWidget {
  final Pedido pedido;
  const AdminDetallePedidoScreen({super.key, required this.pedido});

  @override
  State<AdminDetallePedidoScreen> createState() => _AdminDetallePedidoScreenState();
}

class _AdminDetallePedidoScreenState extends State<AdminDetallePedidoScreen> {
  late int _estadoSeleccionadoId;

  final Map<int, String> _opcionesEstado = {
    1: 'Recibido',
    2: 'Confirmado',
    3: 'En camino',
    4: 'Entregado',
    5: 'Cancelado',
  };

  @override
  void initState() {
    super.initState();
    _estadoSeleccionadoId = widget.pedido.estadoPedidoId;
  }

  Future<void> _actualizarEstado() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    final success = await adminProvider.actualizarEstadoPedido(
      widget.pedido.pedidoId,
      _estadoSeleccionadoId,
    );
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppStyles.successSnackBar('¡Estado actualizado!'),
        );
        Navigator.of(context).pop(); // Vuelve a la lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppStyles.errorSnackBar('Error: ${adminProvider.error}'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle Pedido #${widget.pedido.pedidoId}'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1, // Añadimos elevación
      ),
      backgroundColor: AppStyles.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección 1: Gestión de Estado
            _buildGestionEstado(),
            const SizedBox(height: AppStyles.largePadding),
            // Sección 2: Info del Cliente
            _buildInfoCliente(),
            const SizedBox(height: AppStyles.largePadding),
            // Sección 3: Artículos
            _buildArticulos(),
          ],
        ),
      ),
    );
  }

  Widget _buildGestionEstado() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actualizar Estado del Pedido', style: AppStyles.headingStyle.copyWith(fontSize: 20)),
          const Divider(height: 24),
          DropdownButtonFormField<int>(
            value: _estadoSeleccionadoId,
            decoration: AppStyles.textFieldDecoration('Estado'),
            items: _opcionesEstado.entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _estadoSeleccionadoId = value;
                });
              }
            },
          ),
          const SizedBox(height: AppStyles.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppStyles.primaryButtonStyle,
              onPressed: _actualizarEstado,
              child: const Text('Guardar Estado'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCliente() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Información del Cliente', style: AppStyles.headingStyle.copyWith(fontSize: 20)),
          const Divider(height: 24),
          // Usamos un layout más limpio si la dirección está disponible
          Text(
            'Nombre: ${widget.pedido.clienteNombre} ${widget.pedido.clienteApellido}', 
            style: AppStyles.bodyTextStyle
          ),
          const SizedBox(height: 8),
          Text(
            'Dirección: ${widget.pedido.direccionEnvio?.direccionCompleta ?? 'N/A'}', 
            style: AppStyles.bodyTextStyle
          ),
          const SizedBox(height: 8),
          Text(
            'Método Pago: ${widget.pedido.metodoPagoNombre ?? 'N/A'}', 
            style: AppStyles.bodyTextStyle
          ),
        ],
      ),
    );
  }

  Widget _buildArticulos() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Artículos (${widget.pedido.articulos.length})', style: AppStyles.headingStyle.copyWith(fontSize: 20)),
          const Divider(height: 24),
          ...widget.pedido.articulos.map((articulo) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${articulo.cantidad} x ${articulo.productoNombre ?? 'Producto'}',
                  style: AppStyles.bodyTextStyle,
                ),
                Text(
                  '\$${articulo.subtotal.toStringAsFixed(2)}',
                  style: AppStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Total: ', style: AppStyles.subheadingStyle),
              Text('\$${widget.pedido.total.toStringAsFixed(2)}', style: AppStyles.headingStyle.copyWith(fontSize: 20, color: AppStyles.primaryColor)),
            ],
          ),
        ],
      ),
    );
  }
}