import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../models/resena.dart'; // <-- Asegúrate de tener 'resena.dart' (con 'n')
import '../services/producto_service.dart';
import '../providers/carrito_provider.dart';
import '../utils/app_styles.dart';
import '../utils/constants.dart'; // <-- Importa tus constantes
import '../widgets/responsive_layout.dart'; // <-- Importa el layout responsivo

class DetalleProductoScreen extends StatefulWidget { // <-- EL NOMBRE DE CLASE CORRECTO
  final int productoId; 

  const DetalleProductoScreen({super.key, required this.productoId});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  final ProductoService _productoService = ProductoService();
  late Future<Producto> _productoFuture;
  int _cantidad = 1;

  @override
  void initState() {
    super.initState();
    _productoFuture = _productoService.obtenerProductoPorId(widget.productoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
      ),
      body: ResponsiveLayout(
        child: FutureBuilder<Producto>(
          future: _productoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar el producto: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('Producto no encontrado.'));
            }
            final producto = snapshot.data!;
            return _buildContenidoProducto(producto);
          },
        ),
      ),
    );
  }

  Widget _buildContenidoProducto(Producto producto) {
    final carritoProvider = Provider.of<CarritoProvider>(context, listen: false);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: AppStyles.cardDecoration,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      '$kApiBaseUrl${producto.imagenUrl!}', 
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.local_drink, size: 100),
                    ),
                  ),
                ),
                const SizedBox(height: AppStyles.mediumPadding),
                Text(
                  producto.categoriaNombre ?? 'Categoría',
                  style: AppStyles.captionStyle.copyWith(color: AppStyles.primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  producto.nombre,
                  style: AppStyles.headingStyle.copyWith(fontSize: 28),
                ),
                const SizedBox(height: AppStyles.defaultPadding),
                Text(
                  '\$${producto.precioActual.toStringAsFixed(2)}',
                  style: AppStyles.headingStyle.copyWith(
                    fontSize: 32,
                    color: AppStyles.primaryColor,
                  ),
                ),
                const SizedBox(height: AppStyles.defaultPadding),
                Text(
                  'Descripción',
                  style: AppStyles.subheadingStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  producto.descripcion ?? 'Sin descripción disponible.',
                  style: AppStyles.bodyTextStyle,
                ),
                const SizedBox(height: AppStyles.largePadding),
                _buildSeccionResenas(producto.resenas),
              ],
            ),
          ),
        ),
        _buildBarraCompra(producto, carritoProvider),
      ],
    );
  }

  Widget _buildSeccionResenas(List<Resena> resenas) {
    if (resenas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        decoration: AppStyles.cardDecoration.copyWith(
          color: AppStyles.backgroundColor,
        ),
        child: Center(
          child: Text('Aún no hay reseñas para este producto.', style: AppStyles.captionStyle),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reseñas (${resenas.length})',
          style: AppStyles.subheadingStyle,
        ),
        const SizedBox(height: AppStyles.defaultPadding),
        ...resenas.map((resena) => _buildItemResena(resena)).toList(),
      ],
    );
  }

  Widget _buildItemResena(Resena resena) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                resena.clienteNombre ?? 'Anónimo',
                style: AppStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < resena.puntuacion ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            resena.comentario ?? '',
            style: AppStyles.captionStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildBarraCompra(Producto producto, CarritoProvider carritoProvider) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyles.cardColor,
        border: Border(top: BorderSide(color: AppStyles.borderColor, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
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
                      if (_cantidad > 1) setState(() => _cantidad--);
                    },
                  ),
                  Text(_cantidad.toString(), style: AppStyles.headingStyle.copyWith(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () {
                      setState(() => _cantidad++);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppStyles.defaultPadding),
            Expanded(
              child: ElevatedButton(
                style: AppStyles.primaryButtonStyle,
                onPressed: () {
                  carritoProvider.agregarProducto(producto, _cantidad);
                  ScaffoldMessenger.of(context).showSnackBar(
                    AppStyles.successSnackBar(
                      '$_cantidad x ${producto.nombre} agregado(s) al carrito'
                    ),
                  );
                  Navigator.of(context).pop(); 
                },
                child: const Text('Agregar al Carrito'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}