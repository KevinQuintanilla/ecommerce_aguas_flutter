import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../utils/app_styles.dart';
import '../widgets/producto_card.dart';
import '../providers/navigation_provider.dart';
import '../utils/constants.dart';
import '../widgets/web_page_layout.dart';

const List<Map<String, dynamic>> webCategories = [
  {'name': 'Agua Purificada', 'icon': Icons.water_drop},
  {'name': 'Paquetes y Combos', 'icon': Icons.shopping_bag},
  {'name': 'Especiales', 'icon': Icons.bolt},
  {'name': 'Merchandising', 'icon': Icons.bolt},
];
final List<Map<String, String>> productTabsData = [
  {
    "tab": "355 ML",
    "title": "AGUA MINERAL 355 ML",
    "desc": "PRESENTACIÓN CON TAPARROSCA DE UNA MEDIDA REAL, PARA LLEVARLA A TODOS LADOS Y PARA ACOMPAÑAR LOS ANTOJITOS DEL DÍA, ASÍ COMO EN NUESTRA VIDA NOCTURNA.",
    "image": "/images/agua/agua-355ml.webp"
  },
  {
    "tab": "600 ML",
    "title": "AGUA MINERAL 600 ML",
    "desc": "PRESENTACIÓN CON TAPARROSCA DE UN TAMAÑO PRECISO PARA SER EL ACOMPAÑANTE DURANTE TODO TU DÍA. PERMITIENDO HIDRATARTE SIEMPRE CON EL MEJOR SABOR DE UN AGUA MINERAL.",
    "image": "/images/agua/agua-600ml.webp"
  },
  {
    "tab": "1.5 LTS",
    "title": "AGUA MINERAL 1.5 LTS",
    "desc": "LA PRESENTACIÓN IDEAL PARA SER UN BUEN MEZCLADOR EN NUESTROS EVENTOS SOCIALES QUE, POR SU TAMAÑO, NOS INVITA A COMPARTIRLA CON NUESTROS SERES MÁS QUERIDOS Y CERCANOS.",
    "image": "/images/agua/agua-1.5L.webp" 
  },
  {
    "tab": "200 ML",
    "title": "AGUA MINERAL 200 ML",
    "desc": "EXCELENTE TAMAÑO PARA DARLE UN TOQUE FRESCO A TU DÍA CON LA PRESENTACIÓN EN VIDRIO, INICIANDO UNA RELACIÓN CÍCLICA Y RETORNABLE.",
    "image": "/images/agua/agua-200ml.webp" 
  },
  {
    "tab": "340 ML",
    "title": "AGUA MINERAL 340 ML",
    "desc": "PRESENTACIÓN RETORNABLE DE TAMAÑO IDEAL PARA ACOMPAÑAR LOS SABORES EXQUISITOS DE LA COMIDA CASERA Y DEL AMBIENTE DE FIESTA QUE NOS CARACTERIZA A LOS MEXICANOS.",
    "image": "/images/agua/agua-340ml.webp" 
  },
];

class WebHomeScreen extends StatefulWidget {
  const WebHomeScreen({super.key});

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}
class _WebHomeScreenState extends State<WebHomeScreen> with SingleTickerProviderStateMixin {
  final ProductoService _productoService = ProductoService();
  List<Producto> _featuredProducts = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }
  @override
  void dispose() {
    _tabController.dispose(); 
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      _featuredProducts = await _productoService.obtenerProductosDestacados();
    } catch (e) {
      print('Error al cargar productos web: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return WebPageLayout(
      selectedIndex: 0,
      backgroundColor: AppStyles.backgroundColor,
      body: Column(
        children: [
          _buildHeroSection(context),
          _buildCarouselSection(),
          const SizedBox(height: 60),
          _buildFeaturedProductsSection(context),
          _buildReviewsSection(),
        ],
      ),
    );
  }

//banner 
  Widget _buildHeroSection(BuildContext context) {
  return Container(
    width: double.infinity,
    color: AppStyles.backgroundColor, 
    child: Image.network(
      '$kApiBaseUrl/images/other/banner-300x132.webp',
      fit: BoxFit.cover, 

      // Muestra un 'Cargando...'
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 250, 
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      },
      
      // Muestra un error si no la encuentra
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 250,
          alignment: Alignment.center,
          color: AppStyles.borderColor,
          child: const Icon(Icons.error_outline, color: AppStyles.errorColor),
        );
      },
    ),
  );
}

  // --- SECCIÓN CARRUSEL (PLACEHOLDER) ---
  Widget _buildCarouselSection() {
    return Container(
      color: AppStyles.primaryColor, // Fondo azul oscuro
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          Center(
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppStyles.accentColor, // Línea amarilla
              indicatorWeight: 4.0,
              labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              unselectedLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white70),
              tabs: productTabsData.map((p) => Tab(text: p['tab'])).toList(),
            ),
          ),

          Container(
            height: 450, 
            child: TabBarView(
              controller: _tabController,
              children: productTabsData.map((p) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120.0, vertical: 30.0),
                  child: _ProductTabContent(
                    title: p['title']!,
                    description: p['desc']!,
                    imageUrl: p['image']!,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- SECCIÓN PRODUCTOS DESTACADOS ---
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
                crossAxisCount: 3, 
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.70,
              ),
              itemCount: _featuredProducts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
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
          GridView.count(
            crossAxisCount: 3, // 3 columnas
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.5, // Ajusta esto (ancho/alto)
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
class _ProductTabContent extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const _ProductTabContent({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppStyles.accentColor, // Fondo amarillo
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido
        children: [
          // Columna 1: Imagen (con tamaño fijo)
          Image.network(
            '$kApiBaseUrl$imageUrl', // Carga desde el backend
            fit: BoxFit.contain,
            height: 300, // Altura fija como en el diseño
          ),

          const SizedBox(width: 60), // Más espacio
          
          // Columna 2: Texto (Este sí se expande)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente el texto
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}