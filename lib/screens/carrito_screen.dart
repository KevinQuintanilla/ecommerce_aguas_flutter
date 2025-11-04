import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/carrito_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/carrito_item.dart';
import 'checkout_screen.dart';
import '../widgets/responsive_layout.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carritoProvider = Provider.of<CarritoProvider>(context);

    if (carritoProvider.estaVacio) {
      return _buildCarritoVacio(context);
    }

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
      ),
      body: ResponsiveLayout(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              children: [
                _buildListaItems(carritoProvider),
                const SizedBox(height: 20),
                _buildResumenCompra(carritoProvider),
              ],
            ),
          ),
          _buildBottomBar(carritoProvider, context),
        ],
      ),
      )
    );
  }

  Widget _buildCarritoVacio(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: AppStyles.lightTextColor,
            ),
            const SizedBox(height: 20),
            Text(
              'Tu carrito está vacío',
              style: AppStyles.headingStyle,
            ),
            const SizedBox(height: 10),
            Text(
              'Agrega algunos productos',
              style: AppStyles.bodyTextStyle,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // CORREGIDO: Usar NavigationProvider para navegar a productos
                final navigationProvider =
                    Provider.of<NavigationProvider>(context, listen: false);
                navigationProvider.goToProducts();
              },
              style: AppStyles.primaryButtonStyle.copyWith(
                minimumSize: MaterialStateProperty.all(const Size(200, 50)),
              ),
              child: const Text('Ver Productos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaItems(CarritoProvider carritoProvider) {
    return Container(
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: AppStyles.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Tu Carrito (${carritoProvider.totalItems})',
                  style: AppStyles.headingStyle.copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...carritoProvider.items
              .map((item) => _buildCarritoItem(item, carritoProvider)),
        ],
      ),
    );
  }

  Widget _buildCarritoItem(CarritoItem item, CarritoProvider carritoProvider) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppStyles.borderColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Imagen del producto
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppStyles.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppStyles.borderColor),
            ),
            child: item.imagenUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'http://localhost:3000${item.imagenUrl!}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.local_drink,
                          color: AppStyles.primaryColor,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.local_drink,
                    color: AppStyles.primaryColor,
                  ),
          ),
          const SizedBox(width: 12),

          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombre,
                  style: AppStyles.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.precio.toStringAsFixed(2)}',
                  style: AppStyles.bodyTextStyle.copyWith(
                    color: AppStyles.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Controles de cantidad
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppStyles.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () {
                    carritoProvider.decrementarCantidad(item.productoId);
                  },
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      vertical: BorderSide(color: AppStyles.borderColor),
                    ),
                  ),
                  child: Text(
                    item.cantidad.toString(),
                    style: AppStyles.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () {
                    carritoProvider.incrementarCantidad(item.productoId);
                  },
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Subtotal y botón eliminar
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.subtotal.toStringAsFixed(2)}',
                style: AppStyles.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () {
                  carritoProvider.removerProducto(item.productoId);
                },
                color: AppStyles.errorColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCompra(CarritoProvider carritoProvider) {
    final subtotal = carritoProvider.totalPrecio;
    final impuestos = subtotal * 0.16;
    final total = subtotal + impuestos;

    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          Text(
            'Resumen de Compra',
            style: AppStyles.headingStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildResumenLinea('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          _buildResumenLinea('Envío', '\$0.00'),
          _buildResumenLinea(
              'Impuestos (16%)', '\$${impuestos.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildResumenLinea(
            'Total',
            '\$${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResumenLinea(String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppStyles.headingStyle.copyWith(fontSize: 18)
                : AppStyles.bodyTextStyle,
          ),
          Text(
            value,
            style: isTotal
                ? AppStyles.headingStyle.copyWith(
                    fontSize: 18,
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

  Widget _buildBottomBar(
      CarritoProvider carritoProvider, BuildContext context) {
    final total = carritoProvider.totalPrecio * 1.16;

    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyles.cardColor,
        border: Border(
          top: BorderSide(color: AppStyles.borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: AppStyles.captionStyle,
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: AppStyles.headingStyle.copyWith(
                      fontSize: 20,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // CORREGIDO: Navegar al checkout en lugar de mostrar diálogo
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckoutScreen(),
                  ),
                );
              },
              style: AppStyles.primaryButtonStyle.copyWith(
                minimumSize: MaterialStateProperty.all(const Size(150, 50)),
              ),
              child: const Text('Pagar Ahora'),
            ),
          ],
        ),
      ),
    );
  }
}
