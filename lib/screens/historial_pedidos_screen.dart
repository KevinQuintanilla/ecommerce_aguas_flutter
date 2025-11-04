import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/pedido_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/pedido.dart';
import '../widgets/responsive_layout.dart';

// --- CAMBIO ---
// 1. Borra la importación de 'detalle_producto_screen.dart'
// import 'detalle_producto_screen.dart'; // <-- BORRA ESTA LÍNEA
// 2. Añade la importación de 'detalle_pedido_screen.dart'
import 'detalle_pedido_screen.dart'; 
// --- FIN DE CAMBIO ---


class HistorialPedidosScreen extends StatefulWidget {
  const HistorialPedidosScreen({super.key});

  @override
  State<HistorialPedidosScreen> createState() => _HistorialPedidosScreenState();
}

class _HistorialPedidosScreenState extends State<HistorialPedidosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarPedidos();
    });
  }

  void _cargarPedidos() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);

    if (authProvider.estaAutenticado &&
        authProvider.usuario!.clienteId != null) {
      pedidoProvider.cargarPedidos(authProvider.usuario!.clienteId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = Provider.of<PedidoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
      ),
      body: ResponsiveLayout(
        child: _buildContent(pedidoProvider, authProvider),
      ),
    );
  }

  Widget _buildContent(
      PedidoProvider pedidoProvider, AuthProvider authProvider) {
    if (!authProvider.estaAutenticado) {
      return _buildNoAutenticado();
    }

    if (pedidoProvider.cargando) {
      return _buildCargando();
    }

    if (pedidoProvider.pedidos.isEmpty) {
      return _buildSinPedidos();
    }

    return _buildListaPedidos(pedidoProvider);
  }

  Widget _buildNoAutenticado() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_outline,
            size: 80,
            color: AppStyles.lightTextColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Inicia sesión',
            style: AppStyles.headingStyle,
          ),
          const SizedBox(height: 10),
          Text(
            'Para ver tu historial de pedidos',
            style: AppStyles.bodyTextStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildCargando() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildSinPedidos() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppStyles.lightTextColor,
          ),
          const SizedBox(height: 20),
          Text(
            'No hay pedidos',
            style: AppStyles.headingStyle,
          ),
          const SizedBox(height: 10),
          Text(
            'Aún no has realizado ningún pedido',
            style: AppStyles.bodyTextStyle,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              final navigationProvider =
                  Provider.of<NavigationProvider>(context, listen: false);
              navigationProvider.goToProducts();
            },
            style: AppStyles.primaryButtonStyle.copyWith(
              minimumSize: MaterialStateProperty.all(const Size(200, 50)),
            ),
            child: const Text('Comenzar a Comprar'),
          ),
        ],
      ),
    );
  }

  Widget _buildListaPedidos(PedidoProvider pedidoProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.estaAutenticado &&
            authProvider.usuario!.clienteId != null) {
          await pedidoProvider.cargarPedidos(authProvider.usuario!.clienteId!);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        itemCount: pedidoProvider.pedidos.length,
        itemBuilder: (context, index) {
          final pedido = pedidoProvider.pedidos[index];
          return _buildItemPedido(pedido);
        },
      ),
    );
  }

  
  Widget _buildItemPedido(Pedido pedido) {
    // Envolvemos el Container con InkWell para hacerlo clicable
    return InkWell(
      onTap: () {
        // --- ¡ESTE ES EL CAMBIO QUE ARREGLA EL ERROR! ---
        Navigator.push(
          context,
          MaterialPageRoute(
            // ANTES: builder: (context) => DetalleProductoScreen(productoId: pedido.productoId),
            // AHORA:
            builder: (context) => DetallePedidoScreen(pedido: pedido),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
        decoration: AppStyles.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del pedido
            _buildHeaderPedido(pedido),

            // Artículos del pedido
            _buildArticulosPedido(pedido),

            // Footer del pedido
            _buildFooterPedido(pedido),
          ],
        ),
      ),
    );
  }


  Widget _buildHeaderPedido(Pedido pedido) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyles.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedido #${pedido.pedidoId}',
                style: AppStyles.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatearFecha(pedido.fechaPedido),
                style: AppStyles.captionStyle,
              ),
            ],
          ),
          _buildBadgeEstado(pedido.estadoDisplay, pedido.estadoPedidoId),
        ],
      ),
    );
  }

  Widget _buildBadgeEstado(String estado, int estadoId) {
    Color color;
    switch (estadoId) {
      case 1: // Recibido
        color = AppStyles.infoColor;
        break;
      case 2: // Confirmado
        color = AppStyles.warningColor;
        break;
      case 3: // En camino
        color = AppStyles.primaryColor;
        break;
      case 4: // Entregado
        color = AppStyles.successColor;
        break;
      case 5: // Cancelado
        color = AppStyles.errorColor;
        break;
      default:
        color = AppStyles.lightTextColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildArticulosPedido(Pedido pedido) {
    final primerosArticulos = pedido.articulos.take(2).toList();
    final articulosRestantes = pedido.articulos.length - 2;

    return Padding(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      child: Column(
        children: [
          ...primerosArticulos.map((articulo) => _buildLineaArticulo(articulo)),
          if (articulosRestantes > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ $articulosRestantes producto${articulosRestantes > 1 ? 's' : ''} más',
                style: AppStyles.captionStyle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLineaArticulo(ArticuloPedido articulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppStyles.backgroundColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppStyles.borderColor),
            ),
            child: Icon(
              Icons.local_drink,
              size: 16,
              color: AppStyles.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              articulo.productoNombre ?? 'Producto',
              style: AppStyles.bodyTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${articulo.cantidad} x \$${articulo.precioUnitario.toStringAsFixed(2)}',
            style: AppStyles.captionStyle,
          ),
        ],
      ),
    );
  }

  // En lib/screens/historial_pedidos_screen.dart

  Widget _buildFooterPedido(Pedido pedido) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppStyles.borderColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Columna del Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total',
                style: AppStyles.captionStyle,
              ),
              Text(
                '\$${pedido.total.toStringAsFixed(2)}',
                style: AppStyles.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppStyles.primaryColor,
                ),
              ),
            ],
          ),

          Row(
            children: [
              // Botón de Seguimiento
              if (pedido.estadoPedidoId == 2 || pedido.estadoPedidoId == 3)
                OutlinedButton(
                  onPressed: () {
                    _mostrarDialogoSeguimiento(pedido);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppStyles.primaryColor,
                    side: BorderSide(color: AppStyles.primaryColor),
                  ),
                  child: const Text('Seguimiento'),
                ),
            ],
          )
        ],
      ),
    );
  }

  void _mostrarDialogoSeguimiento(Pedido pedido) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seguimiento de Pedido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pedido #${pedido.pedidoId}'),
            const SizedBox(height: 8),
            Text(
              'Código: ${pedido.codigoSeguimiento ?? 'No disponible'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              'Estado actual: ${pedido.estadoDisplay}',
              style: TextStyle(
                color: _getColorEstado(pedido.estadoPedidoId),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Color _getColorEstado(int estadoId) {
    switch (estadoId) {
      case 1:
        return AppStyles.infoColor;
      case 2:
        return AppStyles.warningColor;
      case 3:
        return AppStyles.primaryColor;
      case 4:
        return AppStyles.successColor;
      case 5:
        return AppStyles.errorColor;
      default:
        return AppStyles.lightTextColor;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}