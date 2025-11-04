import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../utils/app_styles.dart';
import '../widgets/producto_card.dart';
import '../widgets/web_header.dart';
import '../widgets/web_footer.dart';
import '../providers/navigation_provider.dart';

const List<Map<String, dynamic>> webCategories = [
  {'name': 'Agua Purificada', 'icon': Icons.water_drop},
  {'name': 'Paquetes y Combos', 'icon': Icons.shopping_bag},
  {'name': 'Especiales', 'icon': Icons.bolt},
  {'name': 'Merchandising', 'icon': Icons.bolt},
];

class WebHomeScreen extends StatefulWidget {
  const WebHomeScreen({super.key});

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  final ProductoService _productoService = ProductoService();
  List<Producto> _featuredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Cargamos los 3 productos destacados
      final allProducts = await _productoService.obtenerProductos();
      _featuredProducts = allProducts.take(3).toList();
    } catch (e) {
      print('Error al cargar productos web: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el Scaffold para tener una estructura base
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView( // El SingleChildScrollView es el padre de todo
        child: Column(
          children: [
            const WebHeader(selectedIndex: 0), // <-- 1. El Header AHORA ESTÁ AQUÍ
            _buildHeroSection(context), 
            _buildCarouselSection(), 
            _buildCategoriesSection(context),
            _buildFeaturedProductsSection(context),
            _buildReviewsSection(),
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  // --- 2. SECCIÓN "HERO" (EL BANNER AZUL) ---
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      color: AppStyles.primaryColor,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          const Text(
            'Aguas de Lourdes',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pureza desde 1937',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Provider.of<NavigationProvider>(context, listen: false)
                  .goToProducts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.accentColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Comprar ahora'),
          ),
        ],
      ),
    );
  }

  // --- 3. SECCIÓN CARRUSEL (PLACEHOLDER) ---
  Widget _buildCarouselSection() {
    // Placeholder para el carrusel
    return Container(
      height: 400,
      color: Colors.black,
      child: const Center(
        child: Text(
          'Aquí va el Carrusel (Carousel.jsx)',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // --- 4. SECCIÓN CATEGORÍAS ---
  Widget _buildCategoriesSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          const Text(
            'Explora Nuestras Categorías',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppStyles.primaryColor,
            ),
          ),
          const SizedBox(height: 40),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 columnas como en el diseño web
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.0, // Tarjetas cuadradas
            ),
            itemCount: webCategories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final category = webCategories[index];
              return _CategoryCard(
                icon: category['icon'],
                name: category['name'],
                onTap: () {
                  Provider.of<NavigationProvider>(context, listen: false)
                      .goToProducts();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 5. SECCIÓN PRODUCTOS DESTACADOS ---
  Widget _buildFeaturedProductsSection(BuildContext context) {
    return Container(
      color: AppStyles.backgroundColor, // Fondo gris pálido
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          const Text(
            'Productos Destacados',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppStyles.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'La calidad y pureza que nos distingue.',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 40),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 columnas como en el diseño web
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.70, // Relación de aspecto de la tarjeta
              ),
              itemCount: _featuredProducts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                // ¡Usamos el ProductoCard que ya tenías!
                return ProductoCard(producto: _featuredProducts[index]);
              },
            ),
          const SizedBox(height: 40),
          OutlinedButton(
            onPressed: () {
              Provider.of<NavigationProvider>(context, listen: false)
                  .goToProducts();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppStyles.primaryColor,
              side: const BorderSide(color: AppStyles.primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ver toda la tienda'),
                SizedBox(width: 8),
                Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. SECCIÓN RESEÑAS (PLACEHOLDER) ---
  Widget _buildReviewsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          const Text(
            'Lo que dicen nuestros clientes',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppStyles.primaryColor,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            // Replicamos el layout de 3 columnas
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ReviewCard(
                  nombre: 'Ana Pérez',
                  comentario:
                      '"La mejor agua! El servicio de entrega es súper rápido y confiable."'),
              _ReviewCard(
                  nombre: 'Carlos Gómez',
                  comentario:
                      '"Muy buena calidad de agua. Me gustaría que tuvieran más puntos."'),
              _ReviewCard(
                  nombre: 'Luisa Fernández',
                  comentario:
                      '"El agua alcalina es fantástica. Me siento con más energía."'),
            ],
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS INTERNOS DE AYUDA (PARA TRADUCIR LOS COMPONENTES DE REACT) ---
// La tarjeta cuadrada de categoría
class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final VoidCallback onTap;

  const _CategoryCard({required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.blue[50],
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppStyles.backgroundColor, 
          borderRadius: BorderRadius.circular(12), 
        ),
        padding: const EdgeInsets.all(16), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppStyles.primaryColor),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppStyles.primaryColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Una tarjeta simple para las reseñas
class _ReviewCard extends StatelessWidget {
  final String nombre;
  final String comentario;
  const _ReviewCard({required this.nombre, required this.comentario});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(nombre,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: List.generate(
                    5,
                    (i) =>
                        Icon(Icons.star, color: Colors.amber[600], size: 18)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('"$comentario"', style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }
}