import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../providers/carrito_provider.dart';
import '../providers/navigation_provider.dart';

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
      final productos = await _productoService.obtenerProductos();
      setState(() {
        _productosDestacados = productos.take(4).toList();
        _cargandoProductos = false;
      });
    } catch (e) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aguas Lourdes',
                style: AppStyles.companyNameStyle.copyWith(fontSize: 20),
              ),
              Text(
                'Desde 1937',
                style: AppStyles.vintageStyle.copyWith(fontSize: 10),
              ),
            ],
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
                icon: const Icon(Icons.shopping_cart, color: AppStyles.primaryColor),
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

// CONTENIDO PRINCIPAL DEL HOME
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
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con eslogan
          _buildHeader(),
          const SizedBox(height: AppStyles.largePadding),
          
          // Banner principal
          _buildMainBanner(),
          const SizedBox(height: AppStyles.largePadding),
          
          // Categorías
          _buildCategoriesSection(),
          const SizedBox(height: AppStyles.largePadding),
          
          // Productos destacados
          _buildFeaturedProducts(),
          const SizedBox(height: AppStyles.largePadding),
          
          // Promoción especial
          _buildSpecialOffer(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descubre algo naturalmente mineral',
          style: AppStyles.sloganStyle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          'EL SABOR DE SIEMPRE • VACONTODO • DESDE 1937',
          style: AppStyles.vintageStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMainBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppStyles.largePadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppStyles.primaryColor,
            AppStyles.accentColor,
          ],
        ),
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppStyles.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AGUAS LOURDES',
                  style: AppStyles.companyNameStyle.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'EL SABOR DE SIEMPRE',
                  style: AppStyles.bodyTextStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Calidad y tradición desde 1937',
                  style: AppStyles.captionStyle.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    navigationProvider.goToProducts();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppStyles.primaryColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'VER COLECCIÓN',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          const Icon(
            Icons.local_drink,
            size: 100,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'name': 'Mineral', 'icon': Icons.water_drop, 'color': AppStyles.primaryColor},
      {'name': 'Saborizada', 'icon': Icons.emoji_food_beverage, 'color': AppStyles.accentColor},
      {'name': 'Vidrio', 'icon': Icons.liquor, 'color': Colors.amber},
      {'name': 'Promociones', 'icon': Icons.local_offer, 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorías',
          style: AppStyles.headingStyle,
        ),
        const SizedBox(height: AppStyles.defaultPadding),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: categories.map((category) {
              return _buildCategoryItem(
                category['name'] as String,
                category['icon'] as IconData,
                category['color'] as Color,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String name, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        navigationProvider.goToProducts();
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: AppStyles.defaultPadding),
        decoration: AppStyles.cardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: color.withOpacity(0.3), width: 2),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: AppStyles.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Productos Destacados',
              style: AppStyles.headingStyle,
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
          _buildLoadingGrid()
        else if (productosDestacados.isEmpty)
          _buildEmptyProducts()
        else
          _buildProductsGrid(),
      ],
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppStyles.defaultPadding,
      mainAxisSpacing: AppStyles.defaultPadding,
      childAspectRatio: 0.75,
      children: List.generate(4, (index) => _buildProductSkeleton()),
    );
  }

  Widget _buildProductSkeleton() {
    return Container(
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppStyles.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 16,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProducts() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.largePadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          Icon(
            Icons.local_drink_outlined,
            size: 60,
            color: AppStyles.lightTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay productos disponibles',
            style: AppStyles.bodyTextStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return Consumer<CarritoProvider>(
      builder: (context, carritoProvider, child) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppStyles.defaultPadding,
          mainAxisSpacing: AppStyles.defaultPadding,
          childAspectRatio: 0.75,
          children: productosDestacados.map((producto) => _buildProductCard(producto, carritoProvider, context)).toList(),
        );
      },
    );
  }

  Widget _buildProductCard(Producto producto, CarritoProvider carritoProvider, BuildContext context) {
  return Container(
    decoration: AppStyles.cardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppStyles.backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: producto.imagenUrl != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      'http://localhost:3000${producto.imagenUrl!}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.local_drink,
                          size: 40,
                          color: AppStyles.primaryColor.withOpacity(0.7),
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.local_drink,
                    size: 40,
                    color: AppStyles.primaryColor.withOpacity(0.7),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                producto.nombre,
                style: AppStyles.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (producto.categoriaNombre != null)
                Text(
                  producto.categoriaNombre!,
                  style: AppStyles.captionStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              Text(
                '\$${producto.precioActual.toStringAsFixed(2)}',
                style: AppStyles.bodyTextStyle.copyWith(
                  color: AppStyles.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    carritoProvider.agregarProducto(producto);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${producto.nombre} agregado al carrito'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'Deshacer',
                          onPressed: () {
                            carritoProvider.removerProducto(producto.productoId);
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Agregar',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSpecialOffer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppStyles.mediumPadding),
      decoration: BoxDecoration(
        color: AppStyles.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
        border: Border.all(color: AppStyles.accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer,
            size: 40,
            color: AppStyles.accentColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oferta Especial',
                  style: AppStyles.subheadingStyle.copyWith(
                    color: AppStyles.accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '20% de descuento en tu primera compra online',
                  style: AppStyles.bodyTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}