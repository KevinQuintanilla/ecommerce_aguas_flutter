import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/carrito_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/carrito_item.dart';
import 'checkout_screen.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/web_page_layout.dart';

class WebCarritoScreen extends StatelessWidget {
  const WebCarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carritoProvider = Provider.of<CarritoProvider>(context);
    return WebPageLayout(
      selectedIndex: 2,
      backgroundColor: AppStyles.backgroundColor, // Fondo gris
      body: (carritoProvider.estaVacio)
          ? _buildCarritoVacio(context)
          : _buildCarritoLleno(context, carritoProvider),
    );
  }

  // --- WIDGET PARA CARRITO LLENO (DISEÑO WEB) ---
  Widget _buildCarritoLleno(BuildContext context, CarritoProvider carritoProvider) {
    // Usamos ResponsiveLayout para centrar el contenido
    return ResponsiveLayout(
      maxWidth: 1200, // Un poco más ancho para el carrito
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Carrito de Compras',
              style: AppStyles.headingStyle.copyWith(
                fontSize: 36,
                color: AppStyles.primaryColor,
              ),
            ),
            const SizedBox(height: AppStyles.mediumPadding),
            
            // Layout de 2 columnas
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna Izquierda: Lista de Items (ocupa 2/3)
                Expanded(
                  flex: 2,
                  child: _buildListaItems(carritoProvider),
                ),
                const SizedBox(width: AppStyles.largePadding),
                
                // Columna Derecha: Resumen (ocupa 1/3)
                Expanded(
                  flex: 1,
                  child: _buildResumenCompra(context, carritoProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PARA CARRITO VACÍO (DISEÑO WEB) ---
  Widget _buildCarritoVacio(BuildContext context) {
    // Damos una altura mínima para que el footer no suba tanto
    return Container(
      constraints: const BoxConstraints(minHeight: 500),
      alignment: Alignment.center,
      child: Center(
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

  // --- WIDGETS COPIADOS Y ADAPTADOS DE TU MOBILE_CARRITO_SCREEN ---
  
  // Lista de items (adaptada para web)
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
                  'Tus Artículos (${carritoProvider.totalItems})',
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

  // Item individual del carrito (copiado de mobile)
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
          Container(
            width: 60,
            height: 60,
            // (Tu lógica de imagen...)
             child: Icon(Icons.local_drink, color: AppStyles.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nombre, style: AppStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('\$${item.precio.toStringAsFixed(2)}', style: AppStyles.bodyTextStyle.copyWith(color: AppStyles.primaryColor)),
              ],
            ),
          ),
          Container(
            // (Tu lógica de controles de cantidad...)
             child: Row(
              children: [
                IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () => carritoProvider.decrementarCantidad(item.productoId)),
                Text(item.cantidad.toString()),
                IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => carritoProvider.incrementarCantidad(item.productoId)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${item.subtotal.toStringAsFixed(2)}', style: AppStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => carritoProvider.removerProducto(item.productoId), color: AppStyles.errorColor),
            ],
          ),
        ],
      ),
    );
  }

  // Resumen de compra (adaptado para web)
  Widget _buildResumenCompra(BuildContext context, CarritoProvider carritoProvider) {
    final subtotal = carritoProvider.totalPrecio;
    final impuestos = subtotal * 0.16;
    final total = subtotal + impuestos; // (Asumimos envío 0 por ahora)

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
          _buildResumenLinea('Envío', 'Gratis'), // (Simplificado)
          _buildResumenLinea(
              'Impuestos (16%)', '\$${impuestos.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildResumenLinea(
            'Total',
            '\$${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: AppStyles.mediumPadding),
          // Botón de Pagar AHORA va aquí en web
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckoutScreen(),
                ),
              );
            },
            style: AppStyles.primaryButtonStyle,
            child: const Text('Pagar Ahora'),
          ),
        ],
      ),
    );
  }

  // Línea de resumen (copiada de mobile)
  Widget _buildResumenLinea(String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? AppStyles.headingStyle.copyWith(fontSize: 18) : AppStyles.bodyTextStyle),
          Text(value, style: isTotal ? AppStyles.headingStyle.copyWith(fontSize: 18, color: AppStyles.primaryColor) : AppStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}