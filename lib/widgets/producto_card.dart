import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../providers/carrito_provider.dart';
import '../utils/app_styles.dart';

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
                        // Asumimos que la API corre en localhost
                        'http://localhost:3000${producto.imagenUrl!}',
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
                              // Usamos decrementar por si añadió varios
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