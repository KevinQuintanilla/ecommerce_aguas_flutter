import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/carrito_provider.dart';
import '../providers/pedido_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart';
import '../models/metodo_pago.dart';
import '../models/direccion_envio.dart';
import 'confirmacion_pedido_screen.dart';
import '../models/carrito_item.dart';
import '../models/pedido.dart';
import '../widgets/responsive_layout.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int? _metodoPagoSeleccionado;
  int? _metodoEnvioSeleccionado;
  final TextEditingController _notasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pedidoProvider.cargarMetodosPago().then((_) {
        print('Métodos de pago cargados: ${pedidoProvider.metodosPago.length}');
      });

      pedidoProvider.cargarMetodosEnvio().then((_) {
        print(
            'Métodos de envío cargados: ${pedidoProvider.metodosEnvio.length}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final carritoProvider = Provider.of<CarritoProvider>(context);
    final pedidoProvider = Provider.of<PedidoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final subtotal = carritoProvider.totalPrecio;
    final costoEnvio = _getCostoEnvio();
    final impuestos = subtotal * 0.16;
    final total = subtotal + impuestos + costoEnvio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Compra'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
      ),
      body: ResponsiveLayout(
        child: carritoProvider.estaVacio
            ? _buildCarritoVacio()
            : _buildCheckoutContent(
                carritoProvider,
                pedidoProvider,
                authProvider,
                subtotal,
                costoEnvio,
                impuestos,
                total,
              ),
      ),
    );
  }

  Widget _buildCarritoVacio() {
    return Center(
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
            'Agrega algunos productos antes de finalizar la compra',
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
    );
  }

  Widget _buildCheckoutContent(
    CarritoProvider carritoProvider,
    PedidoProvider pedidoProvider,
    AuthProvider authProvider,
    double subtotal,
    double costoEnvio,
    double impuestos,
    double total,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen del pedido
          _buildResumenPedido(
              carritoProvider, subtotal, costoEnvio, impuestos, total),

          const SizedBox(height: AppStyles.largePadding),

          // Dirección de envío
          _buildDireccionEnvio(),

          const SizedBox(height: AppStyles.largePadding),

          // Método de envío
          _buildMetodoEnvio(pedidoProvider),

          const SizedBox(height: AppStyles.largePadding),

          // Método de pago
          _buildMetodoPago(pedidoProvider),

          const SizedBox(height: AppStyles.largePadding),

          // Notas adicionales
          _buildNotasAdicionales(),

          const SizedBox(height: AppStyles.largePadding),

          // Botón de confirmar pedido
          _buildBotonConfirmar(
            carritoProvider,
            pedidoProvider,
            authProvider,
            total,
          ),
        ],
      ),
    );
  }

  Widget _buildResumenPedido(
    CarritoProvider carritoProvider,
    double subtotal,
    double costoEnvio,
    double impuestos,
    double total,
  ) {
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

          // Lista de productos
          ...carritoProvider.items.map((item) => _buildItemResumen(item)),

          const Divider(height: 24),

          // Totales
          _buildLineaTotal('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          _buildLineaTotal('Envío', '\$${costoEnvio.toStringAsFixed(2)}'),
          _buildLineaTotal(
              'Impuestos (16%)', '\$${impuestos.toStringAsFixed(2)}'),
          const Divider(height: 16),
          _buildLineaTotal(
            'Total',
            '\$${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildItemResumen(CarritoItem item) {
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
            child: item.imagenUrl != null
                ? Icon(Icons.local_drink, color: AppStyles.primaryColor)
                : Icon(Icons.local_drink, color: AppStyles.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombre,
                  style: AppStyles.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Cantidad: ${item.cantidad}',
                  style: AppStyles.captionStyle,
                ),
              ],
            ),
          ),
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
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

  Widget _buildDireccionEnvio() {
    // Por simplicidad, usamos una dirección temporal
    // En una app real, aquí iría la selección de direcciones del usuario
    final direccionTemporal = DireccionEnvio(
      direccionId: 1,
      clienteId: 1,
      tipo: 'envío',
      calle: 'Av. Ejemplo',
      numeroExterior: '123',
      colonia: 'Centro',
      ciudad: 'Ciudad de México',
      estado: 'CDMX',
      codigoPostal: '01000',
    );

    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppStyles.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Dirección de Envío',
                style: AppStyles.headingStyle.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            direccionTemporal.direccionCompleta,
            style: AppStyles.bodyTextStyle,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Aquí iría la navegación a la pantalla de gestión de direcciones
            },
            child: const Text('Cambiar dirección'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetodoEnvio(PedidoProvider pedidoProvider) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping, color: AppStyles.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Método de Envío',
                style: AppStyles.headingStyle.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pedidoProvider.metodosEnvio.isEmpty)
            const Text('Cargando métodos de envío...')
          else
            ...pedidoProvider.metodosEnvio
                .map((metodo) => _buildItemMetodoEnvio(metodo)),
        ],
      ),
    );
  }

  Widget _buildItemMetodoEnvio(MetodoEnvio metodo) {
    return RadioListTile<int>(
      title: Text(metodo.nombre),
      subtitle: Text(
        '\$${metodo.costo.toStringAsFixed(2)} - ${metodo.tiempoEstimado ?? ''}',
      ),
      value: metodo.metodoEnvioId,
      groupValue: _metodoEnvioSeleccionado,
      onChanged: (value) {
        setState(() {
          _metodoEnvioSeleccionado = value;
        });
      },
      activeColor: AppStyles.primaryColor,
    );
  }

  Widget _buildMetodoPago(PedidoProvider pedidoProvider) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment, color: AppStyles.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Método de Pago',
                style: AppStyles.headingStyle.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pedidoProvider.metodosPago.isEmpty)
            const Text('Cargando métodos de pago...')
          else
            ...pedidoProvider.metodosPago
                .map((metodo) => _buildItemMetodoPago(metodo)),
        ],
      ),
    );
  }

  Widget _buildItemMetodoPago(MetodoPago metodo) {
    return RadioListTile<int>(
      title: Text(metodo.nombre),
      subtitle: Text(metodo.descripcion ?? ''),
      value: metodo.metodoPagoId,
      groupValue: _metodoPagoSeleccionado,
      onChanged: (value) {
        setState(() {
          _metodoPagoSeleccionado = value;
        });
      },
      activeColor: AppStyles.primaryColor,
    );
  }

  Widget _buildNotasAdicionales() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.note, color: AppStyles.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Notas Adicionales',
                style: AppStyles.headingStyle.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notasController,
            decoration: const InputDecoration(
              hintText: 'Instrucciones especiales para la entrega...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildBotonConfirmar(
    CarritoProvider carritoProvider,
    PedidoProvider pedidoProvider,
    AuthProvider authProvider,
    double total,
  ) {
    final isValid =
        _metodoPagoSeleccionado != null && _metodoEnvioSeleccionado != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: !isValid || pedidoProvider.cargando
            ? null
            : () async {
                await _confirmarPedido(
                  carritoProvider,
                  pedidoProvider,
                  authProvider,
                  total,
                );
              },
        style: AppStyles.primaryButtonStyle.copyWith(
          minimumSize:
              MaterialStateProperty.all(const Size(double.infinity, 56)),
        ),
        child: pedidoProvider.cargando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Confirmar Pedido',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _confirmarPedido(
    CarritoProvider carritoProvider,
    PedidoProvider pedidoProvider,
    AuthProvider authProvider,
    double total,
  ) async {
    // Preparar items para el pedido
    final items = carritoProvider.items.map((item) {
      return {
        'producto_id': item.productoId,
        'cantidad': item.cantidad,
        'precio': item.precio,
      };
    }).toList();

    // Crear el pedido
    final resultado = await pedidoProvider.crearPedido(
      clienteId: authProvider.usuario!.clienteId ?? 1, // Temporal
      direccionEnvioId: 1, // Temporal - primera dirección
      metodoPagoId: _metodoPagoSeleccionado!,
      metodoEnvioId: _metodoEnvioSeleccionado!,
      items: items,
      notas: _notasController.text.isEmpty ? null : _notasController.text,
    );

    if (resultado['success'] == true && context.mounted) {
      // Limpiar carrito
      carritoProvider.limpiarCarrito();

      // Navegar a pantalla de confirmación
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ConfirmacionPedidoScreen(
            pedido: resultado['pedido'] as Pedido,
          ),
        ),
      );
    } else if (context.mounted) {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['error'] ?? 'Error al crear pedido'),
          backgroundColor: AppStyles.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  double _getCostoEnvio() {
    if (_metodoEnvioSeleccionado == null) return 0.0;

    final pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);
    final metodo = pedidoProvider.metodosEnvio.firstWhere(
      (m) => m.metodoEnvioId == _metodoEnvioSeleccionado,
      orElse: () => MetodoEnvio(
        metodoEnvioId: 0,
        nombre: '',
        costo: 0.0,
        activo: true,
      ),
    );

    return metodo.costo;
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }
}
