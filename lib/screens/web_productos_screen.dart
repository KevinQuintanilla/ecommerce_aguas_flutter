import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../utils/app_styles.dart';
import '../providers/categoria_provider.dart';
import 'detalle_producto_screen.dart';
import '../widgets/producto_card.dart';
import '../widgets/web_page_layout.dart';

class WebProductosScreen extends StatefulWidget {
  const WebProductosScreen({super.key});

  @override
  State<WebProductosScreen> createState() => _WebProductosScreenState();
}

class _WebProductosScreenState extends State<WebProductosScreen> {
  final ProductoService _productoService = ProductoService();
  Future<List<Producto>>? _productosFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final categoriaId =
        Provider.of<CategoriaProvider>(context).categoriaSeleccionadaId;
    _productosFuture = _cargarProductos(categoriaId: categoriaId);
  }

  Future<List<Producto>> _cargarProductos({int? categoriaId}) async {
    return _productoService.obtenerProductos(categoriaId: categoriaId);
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) {
      return 4;
    } else if (screenWidth > 800) {
      return 3;
    } else {
      // En web, 2 es un buen mínimo
      return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int columnCount = _calculateCrossAxisCount(screenWidth);

    // --- 2. REEMPLAZA EL WIDGET BUILD ---
    return WebPageLayout(
      selectedIndex: 1,
      backgroundColor: AppStyles.backgroundColor, // Fondo gris
      body: Column(
        children: [
          // Título de la página
          Padding(
            padding: const EdgeInsets.all(AppStyles.largePadding),
            child: Text(
              'Nuestros Productos',
              style: AppStyles.headingStyle.copyWith(
                fontSize: 36,
                color: AppStyles.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Barra de Filtros
          _buildFiltrosCategorias(context),

          // Contenido (Grid de productos)
          Padding(
            padding: const EdgeInsets.all(AppStyles.largePadding),
            child: Consumer<CategoriaProvider>(
              builder: (context, categoriaProvider, child) {
                _productosFuture = _cargarProductos(
                    categoriaId: categoriaProvider.categoriaSeleccionadaId);
                
                return FutureBuilder<List<Producto>>(
                  future: _productosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildCargando(columnCount);
                    }
                    if (snapshot.hasError) {
                      return _buildError(snapshot.error.toString());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildVacio();
                    }
                    return _buildProductosGrid(snapshot.data!, columnCount);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- (Los widgets _buildFiltros, Grid, Cargando, Error, Vacio
  //       son copiados de tu mobile_productos_screen.dart) ---

  Widget _buildFiltrosCategorias(BuildContext context) {
    final provider = Provider.of<CategoriaProvider>(context);
    if (provider.cargando) {
      return const Center(child: LinearProgressIndicator());
    }
    final categorias = provider.categoriasParaFiltro;

    return Container(
      height: 60.0,
      color: AppStyles.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length + 1,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index == 0) {
            final bool estaSeleccionada =
                provider.categoriaSeleccionadaId == null;
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
              child: ChoiceChip(
                label: const Text('Todas'),
                selected: estaSeleccionada,
                onSelected: (selected) {
                  provider.seleccionarCategoria(null);
                },
                selectedColor: AppStyles.primaryColor,
                labelStyle: TextStyle(
                  color: estaSeleccionada ? Colors.white : AppStyles.textColor,
                ),
              ),
            );
          }
          final categoria = categorias[index - 1];
          final bool estaSeleccionada =
              provider.categoriaSeleccionadaId == categoria.categoriaId;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
            child: ChoiceChip(
              label: Text(categoria.nombre),
              selected: estaSeleccionada,
              onSelected: (selected) {
                provider.seleccionarCategoria(categoria.categoriaId);
              },
              selectedColor: AppStyles.primaryColor,
              labelStyle: TextStyle(
                color: estaSeleccionada ? Colors.white : AppStyles.textColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductosGrid(List<Producto> productos, int columnCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        crossAxisSpacing: AppStyles.defaultPadding,
        mainAxisSpacing: AppStyles.defaultPadding,
        childAspectRatio: 0.70,
      ),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DetalleProductoScreen(productoId: producto.productoId),
              ),
            );
          },
          child: ProductoCard(producto: producto),
        );
      },
    );
  }

  Widget _buildCargando(int columnCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        crossAxisSpacing: AppStyles.defaultPadding,
        mainAxisSpacing: AppStyles.defaultPadding,
        childAspectRatio: 0.70,
      ),
      itemCount: columnCount * 3,
      itemBuilder: (context, index) => const _ProductoSkeletonCard(),
    );
  }

  Widget _buildError(String error) {
    return Center( /* (Tu widget de error) */ );
  }

  Widget _buildVacio() {
    return Center( /* (Tu widget vacío) */ );
  }
}

// --- WIDGET DE ESQUELETO (COPIADO DE TU MOBILE_PRODUCTOS_SCREEN) ---
class _ProductoSkeletonCard extends StatelessWidget {
  const _ProductoSkeletonCard();

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.grey[300]),
                const SizedBox(height: 8),
                Container(width: 60, height: 16, color: Colors.grey[300]),
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
}