import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/direccion_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_styles.dart';
import '../models/direccion_envio.dart';
import 'form_direccion_screen.dart'; 
import '../widgets/responsive_layout.dart'; 

class DireccionesScreen extends StatefulWidget {
  const DireccionesScreen({super.key});

  @override
  State<DireccionesScreen> createState() => _DireccionesScreenState();
}

class _DireccionesScreenState extends State<DireccionesScreen> {
  @override
  void initState() {
    super.initState();
    // Carga las direcciones tan pronto como la pantalla esté lista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDirecciones();
    });
  }

  void _cargarDirecciones() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.estaAutenticado && authProvider.usuario?.clienteId != null) {
      // Llama al provider para obtener los datos de la API
      Provider.of<DireccionProvider>(context, listen: false)
          .cargarDirecciones(authProvider.usuario!.clienteId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Direcciones'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
      ),
      body: ResponsiveLayout(
        child: Consumer<DireccionProvider>(
          builder: (context, provider, child) {
            if (provider.cargando) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error.isNotEmpty) {
              return Center(child: Text('Error: ${provider.error}'));
            }

            if (provider.direcciones.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, size: 80, color: AppStyles.lightTextColor),
                    const SizedBox(height: 16),
                    Text('No tienes direcciones guardadas', style: AppStyles.headingStyle.copyWith(fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text('Añade una nueva dirección para tus envíos'),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              itemCount: provider.direcciones.length,
              itemBuilder: (context, index) {
                final direccion = provider.direcciones[index];
                return _buildDireccionCard(direccion, provider);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navega al formulario en modo "Agregar" (pasando null)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormDireccionScreen(direccion: null),
            ),
          );
        },
        backgroundColor: AppStyles.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget para construir cada tarjeta de dirección
  Widget _buildDireccionCard(DireccionEnvio direccion, DireccionProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la tarjeta (Tipo y Ciudad)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                direccion.tipo == 'envío' ? 'Dirección de Envío' : 'Facturación',
                style: AppStyles.subheadingStyle.copyWith(fontSize: 16),
              ),
              Chip(
                label: Text(direccion.ciudad, style: const TextStyle(fontSize: 12)),
                backgroundColor: AppStyles.backgroundColor,
                side: BorderSide.none,
              ),
            ],
          ),
          const Divider(height: 20),
          
          // Cuerpo de la tarjeta (Datos de la dirección)
          Text(
            direccion.calle + (direccion.numeroExterior != null ? ' #${direccion.numeroExterior}' : ''),
            style: AppStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          if (direccion.colonia != null && direccion.colonia!.isNotEmpty) 
            Text(direccion.colonia!, style: AppStyles.bodyTextStyle),
          Text(
            '${direccion.ciudad}, ${direccion.estado}, C.P. ${direccion.codigoPostal}',
            style: AppStyles.bodyTextStyle,
          ),
          if (direccion.referencias != null && direccion.referencias!.isNotEmpty)
            Text('Ref: ${direccion.referencias!}', style: AppStyles.captionStyle),
          
          const Divider(height: 20),
          
          // Footer de la tarjeta (Botones de acción)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppStyles.warningColor),
                onPressed: () {
                  // Navega al formulario en modo "Editar" (pasando la dirección)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormDireccionScreen(direccion: direccion),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppStyles.errorColor),
                onPressed: () {
                  // Muestra un diálogo de confirmación antes de eliminar
                  _mostrarDialogoEliminar(context, provider, direccion.direccionId);
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  // Diálogo de confirmación para eliminar
  void _mostrarDialogoEliminar(BuildContext context, DireccionProvider provider, int direccionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Dirección'),
        content: const Text('¿Estás seguro de que quieres eliminar esta dirección?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Llama al provider para eliminar la dirección
              provider.eliminarDireccion(direccionId);
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: AppStyles.errorColor)),
          ),
        ],
      ),
    );
  }
}