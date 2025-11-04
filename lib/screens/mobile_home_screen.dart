import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../providers/carrito_provider.dart';
import '../providers/navigation_provider.dart';
import '../utils/constants.dart'; 
import '../widgets/producto_card.dart'; 

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  final ProductoService _productoService = ProductoService();
  List<Producto> _productosDestacados = [];
  bool _cargandoProductos = true;

  @override
  void initState() {
    super.initState();
    _cargarProductosDestacados();
  }

  Future<void> _cargarProductosDestacados() async {
    try {
      final productos = await _productoService.obtenerProductosDestacados();
      setState(() {
        _productosDestacados = productos;
        _cargandoProductos = false;
      });
    } catch (e) {
      print('Error cargando productos destacados (móvil): $e');
      setState(() {
        _cargandoProductos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final carritoProvider = Provider.of<CarritoProvider>(context);

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor, 
      appBar: _buildAppBar(navigationProvider, carritoProvider),
      body: _HomeContent(
        productosDestacados: _productosDestacados,
        cargandoProductos: _cargandoProductos,
        navigationProvider: navigationProvider,
      ),
    );
  }

  AppBar _buildAppBar(NavigationProvider navigationProvider, CarritoProvider carritoProvider) {
    return AppBar(
      backgroundColor: AppStyles.cardColor,
      elevation: 1,
      title: Row(
        children: [
          const Icon(Icons.local_drink, color: AppStyles.primaryColor, size: 28),
          const SizedBox(width: 12),
          Text(
            'Aguas Lourdes',
            style: AppStyles.companyNameStyle.copyWith(fontSize: 20, color: AppStyles.primaryColor),
          ),
        ],
      ),
      actions: [
        Consumer<CarritoProvider>(
          builder: (context, carritoProvider, child) {
            return Badge(
              label: Text(carritoProvider.totalItems.toString()),
              isLabelVisible: carritoProvider.totalItems > 0,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppStyles.primaryColor),
                onPressed: () {
                  navigationProvider.goToCart();
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
class _HomeContent extends StatelessWidget {
  final List<Producto> productosDestacados;
  final bool cargandoProductos;
  final NavigationProvider navigationProvider;
  const _HomeContent({
    required this.productosDestacados,
    required this.cargandoProductos,
    required this.navigationProvider,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Banner 
          _buildHeroImage(),
          // 2. Productos destacados
          _buildFeaturedProducts(context),
        ],
      ),
    );
  }

  // --- WIDGET: BANNER ---
  Widget _buildHeroImage() {
    return Image.network(
      '$kApiBaseUrl/images/other/banner-300x132.webp',
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 150,
        color: AppStyles.borderColor,
        child: const Icon(Icons.error),
      ),
    );
  }

  // --- WIDGET: PRODUCTOS DESTACADOS ---
  Widget _buildFeaturedProducts(BuildContext context) {
    return Container(
      color: AppStyles.cardColor, // Fondo blanco
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Productos Destacados',
                style: AppStyles.headingStyle.copyWith(fontSize: 20),
              ),
              TextButton(
                onPressed: () {
                  navigationProvider.goToProducts();
                },
                child: Text(
                  'Ver todos',
                  style: AppStyles.bodyTextStyle.copyWith(
                    color: AppStyles.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.defaultPadding),
          
          if (cargandoProductos)
            const Center(child: CircularProgressIndicator())
          else if (productosDestacados.isEmpty)
            _buildEmptyProducts()
          else
            _buildProductsGrid(),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppStyles.defaultPadding,
        mainAxisSpacing: AppStyles.defaultPadding,
        childAspectRatio: 0.70,
      ),
      itemCount: productosDestacados.length,
      itemBuilder: (context, index) {
        return ProductoCard(producto: productosDestacados[index]);
      },
    );
  }

  Widget _buildEmptyProducts() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text('No hay productos destacados en este momento.'),
      ),
    );
  }
}