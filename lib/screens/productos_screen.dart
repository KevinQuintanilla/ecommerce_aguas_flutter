import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../utils/app_styles.dart';
import '../providers/categoria_provider.dart';
import '../utils/constants.dart'; 
import '../providers/carrito_provider.dart'; 

// --- ¡ESTA ES LA LÍNEA QUE FALTABA! ---
import 'detalle_producto_screen.dart'; 
// --- FIN DE LA CORRECCIÓN ---

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoService _productoService = ProductoService();
  Future<List<Producto>>? _productosFuture;

  @override
  void initState() {
    super.initState();
    // La carga ahora se dispara desde didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtiene el ID seleccionado del provider
    final categoriaId =
        Provider.of<CategoriaProvider>(context).categoriaSeleccionadaId;
    // Llama al futuro con el ID (que puede ser null)
    _productosFuture = _cargarProductos(categoriaId: categoriaId);
  }

  Future<List<Producto>> _cargarProductos({int? categoriaId}) async {
    return _productoService.obtenerProductos(categoriaId: categoriaId);
  }

  // --- NUEVA FUNCIÓN ---
  // Calcula el número de columnas basado en el ancho de la pantalla
  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) {
      return 4; // Pantallas de escritorio grandes
    } else if (screenWidth > 800) {
      return 3; // Tablets o web más pequeño
    } else {
      return 2; // Celulares (como estaba antes)
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- NUEVA LÓGICA ---
    // Obtenemos el ancho de la pantalla aquí
    final double screenWidth = MediaQuery.of(context).size.width;
    // Calculamos el número de columnas
    final int columnCount = _calculateCrossAxisCount(screenWidth);
    // --- FIN DE NUEVA LÓGICA ---

    // Usamos un 'Consumer' para escuchar cambios en CategoriaProvider
    return Consumer<CategoriaProvider>(
      builder: (context, categoriaProvider, child) {
        // Disparamos la recarga de productos CADA VEZ que el ID seleccionado cambie
        _productosFuture = _cargarProductos(
            categoriaId: categoriaProvider.categoriaSeleccionadaId);

        return Scaffold(
          backgroundColor: AppStyles.backgroundColor,
          appBar: AppBar(
            title: const Text('Nuestros Productos'),
            backgroundColor: AppStyles.cardColor,
            foregroundColor: AppStyles.primaryColor,
            elevation: 1,
            // --- AÑADIMOS LA BARRA DE FILTROS ---
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: _buildFiltrosCategorias(categoriaProvider),
            ),
            // --- FIN DE FILTROS ---
          ),
          body: FutureBuilder<List<Producto>>(
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
          ),
        );
      },
    );
  }

  // --- WIDGET NUEVO PARA LOS FILTROS ---
  Widget _buildFiltrosCategorias(CategoriaProvider provider) {
    if (provider.cargando) {
      return const Center(child: LinearProgressIndicator());
    }

    // Usamos 'categoriasParaFiltro' del provider
    final categorias = provider.categoriasParaFiltro;

    return Container(
      height: 50.0,
      color: AppStyles.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length + 1, // +1 por el botón "Todas"
        itemBuilder: (context, index) {
          // Botón "Todas"
          if (index == 0) {
            final bool estaSeleccionada =
                provider.categoriaSeleccionadaId == null;
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
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

          // Botones del resto de categorías
          final categoria = categorias[index - 1];
          final bool estaSeleccionada =
              provider.categoriaSeleccionadaId == categoria.categoriaId;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
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

  // --- EL RESTO DE WIDGETS (Grid, Cargando, Error, Vacio) ---
  
  // <-- CAMBIO: Acepta 'columnCount' como parámetro
  Widget _buildProductosGrid(List<Producto> productos, int columnCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount, // <-- CAMBIO (ya no es '2')
        crossAxisSpacing: AppStyles.defaultPadding,
        mainAxisSpacing: AppStyles.defaultPadding,
        childAspectRatio: 0.70, // Ajusta esto para el tamaño
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
                    DetalleProductoScreen(productoId: producto.productoId), // <-- Esta línea da el error
              ),
            );
          },
          child: ProductoCard(producto: producto), // <-- WIDGET REUTILIZABLE
        );
      },
    );
  }

  Widget _buildCargando(int columnCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount, // <-- CAMBIO (ya no es '2')
        crossAxisSpacing: AppStyles.defaultPadding,
        mainAxisSpacing: AppStyles.defaultPadding,
        childAspectRatio: 0.70,
      ),
      itemCount: columnCount * 3,
      itemBuilder: (context, index) => const _ProductoSkeletonCard(),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: AppStyles.errorColor, size: 60),
            const SizedBox(height: 16),
            Text('Error al cargar productos', style: AppStyles.subheadingStyle),
            const SizedBox(height: 8),
            Text(error,
                style: AppStyles.captionStyle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined,
              size: 80, color: AppStyles.lightTextColor),
          const SizedBox(height: 20),
          Text('No hay productos', style: AppStyles.headingStyle),
          const SizedBox(height: 10),
          Text('No se encontraron productos en esta categoría.',
              style: AppStyles.bodyTextStyle),
        ],
      ),
    );
  }
}

// ===================================================================
// --- WIDGET DE PRODUCTO AÑADIDO 
// ===================================================================
class ProductoCard extends StatelessWidget {
  final Producto producto;

  const ProductoCard({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    final carritoProvider = Provider.of<CarritoProvider>(context, listen: false);

    return Container(
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
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
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: producto.imagenUrl != null
                    ? Image.network(
                        // Usamos la variable global para la URL
                        '$kApiBaseUrl${producto.imagenUrl!}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.local_drink,
                            size: 40,
                            color: AppStyles.primaryColor.withOpacity(0.7),
                          );
                        },
                      )
                    : Icon(
                        Icons.local_drink,
                        size: 40,
                        color: AppStyles.primaryColor.withOpacity(0.7),
                      ),
              ),
            ),
          ),
          
          // Contenido (Nombre, Precio, Botón)
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
                              carritoProvider.decrementarCantidad(producto.productoId);
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
}


// Widget de esqueleto (sin cambios)
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