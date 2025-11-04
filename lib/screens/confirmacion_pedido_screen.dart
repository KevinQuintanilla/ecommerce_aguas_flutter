import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../models/pedido.dart';
import '../providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'historial_pedidos_screen.dart';
import '../widgets/responsive_layout.dart';

class ConfirmacionPedidoScreen extends StatelessWidget {
  final Pedido pedido;

  const ConfirmacionPedidoScreen({
    super.key,
    required this.pedido,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedido Confirmado'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
        automaticallyImplyLeading: false, 
      ),
      body: ResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.defaultPadding),
          child: Column(
          children: [
            // Icono de éxito
            _buildIconoExito(),
            const SizedBox(height: AppStyles.largePadding),
            
            // Información del pedido
            _buildInfoPedido(),
            const SizedBox(height: AppStyles.largePadding),
            
            // Resumen del pedido
            _buildResumenPedido(),
            const SizedBox(height: AppStyles.largePadding),
            
            // Botones de acción
            _buildBotonesAccion(context),
          ],
        ),
      ),
      )
    );
  }

  Widget _buildIconoExito() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppStyles.successColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppStyles.successColor,
          width: 3,
        ),
      ),
      child: Icon(
        Icons.check,
        size: 50,
        color: AppStyles.successColor,
      ),
    );
  }

  Widget _buildInfoPedido() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          Text(
            '¡Pedido Confirmado!',
            style: AppStyles.headingStyle.copyWith(
              fontSize: 24,
              color: AppStyles.successColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Tu pedido ha sido procesado exitosamente',
            style: AppStyles.bodyTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildInfoItem('Número de Pedido', '#${pedido.pedidoId}'),
          _buildInfoItem('Código de Seguimiento', pedido.codigoSeguimiento ?? 'Por generar'),
          _buildInfoItem('Fecha', _formatearFecha(pedido.fechaPedido)),
          _buildInfoItem('Estado', pedido.estadoDisplay),
          _buildInfoItem('Total', '\$${pedido.total.toStringAsFixed(2)}'),
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
          Text(
            label,
            style: AppStyles.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: AppStyles.bodyTextStyle.copyWith(
              color: AppStyles.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenPedido() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del Pedido',
            style: AppStyles.headingStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          
          // Artículos del pedido
          ...pedido.articulos.map((articulo) => _buildArticuloResumen(articulo)),
          
          const Divider(height: 24),
          
          // Totales
          _buildLineaTotal('Subtotal', '\$${pedido.subtotal.toStringAsFixed(2)}'),
          _buildLineaTotal('Envío', '\$${(pedido.total - pedido.subtotal - pedido.impuestos).toStringAsFixed(2)}'),
          _buildLineaTotal('Impuestos', '\$${pedido.impuestos.toStringAsFixed(2)}'),
          const Divider(height: 16),
          _buildLineaTotal(
            'Total',
            '\$${pedido.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildArticuloResumen(ArticuloPedido articulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppStyles.backgroundColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppStyles.borderColor),
            ),
            child: articulo.imagenUrl != null
                ? Icon(Icons.local_drink, color: AppStyles.primaryColor)
                : Icon(Icons.local_drink, color: AppStyles.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  articulo.productoNombre ?? 'Producto',
                  style: AppStyles.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Cantidad: ${articulo.cantidad}',
                  style: AppStyles.captionStyle,
                ),
              ],
            ),
          ),
          Text(
            '\$${articulo.subtotal.toStringAsFixed(2)}',
            style: AppStyles.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineaTotal(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppStyles.headingStyle.copyWith(fontSize: 16)
                : AppStyles.bodyTextStyle,
          ),
          Text(
            value,
            style: isTotal
                ? AppStyles.headingStyle.copyWith(
                    fontSize: 16,
                    color: AppStyles.primaryColor,
                  )
                : AppStyles.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonesAccion(BuildContext context) {
  return Column(
    children: [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
            final navigator = Navigator.of(context);
            navigationProvider.goToProfile();
            navigator.popUntil((route) => route.isFirst);
            navigator.push(
              MaterialPageRoute(
                builder: (context) => const HistorialPedidosScreen(),
              ),
            );
          },
          style: AppStyles.primaryButtonStyle.copyWith(
            minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
          ),
          child: const Text('Ver Mis Pedidos'), 
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
            navigationProvider.goToHome();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: AppStyles.secondaryButtonStyle.copyWith(
            minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
          ),
          child: const Text('Seguir Comprando'),
        ),
      ),
    ],
  );
}

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}