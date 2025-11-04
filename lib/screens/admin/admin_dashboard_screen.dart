import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_styles.dart';
import 'admin_pedidos_list_screen.dart';
import 'admin_nuevo_producto_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<AuthProvider>(context).usuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1, // Añadimos elevación
      ),
      backgroundColor: AppStyles.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de Bienvenida
            Text(
              'Bienvenido, ${usuario?.nombre ?? 'Admin'}',
              // --- CAMBIO DE ESTILO ---
              style: AppStyles.headingStyle.copyWith(fontSize: 28, color: AppStyles.primaryColor), 
            ),
            Text(
              'Selecciona una tarea para continuar.',
              style: AppStyles.bodyTextStyle.copyWith(color: AppStyles.lightTextColor),
            ),
            const SizedBox(height: AppStyles.largePadding),
            
            // Botón 1: Gestionar Pedidos
            _AdminMenuButton(
              icon: Icons.history,
              title: 'Gestionar Pedidos',
              subtitle: 'Ver y actualizar el estado de todos los pedidos',
              iconColor: AppStyles.infoColor, // Color azul informativo
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPedidosListScreen()),
                );
              },
            ),
            
            const SizedBox(height: AppStyles.defaultPadding),
            
            // Botón 2: Añadir Producto
            _AdminMenuButton(
              icon: Icons.add_box,
              title: 'Añadir Producto Nuevo',
              subtitle: 'Agregar un nuevo artículo al catálogo de la tienda',
              iconColor: AppStyles.successColor, // Color verde de éxito
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminNuevoProductoScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de ayuda para el botón del menú
class _AdminMenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor; // <-- Nuevo: Parámetro para el color del ícono

  const _AdminMenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.iconColor, // <-- Requerido
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
        side: const BorderSide(color: AppStyles.borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppStyles.defaultPadding),
        leading: Icon(icon, size: 40, color: iconColor), // <-- Usamos el color
        title: Text(title, style: AppStyles.subheadingStyle.copyWith(color: AppStyles.textColor)),
        subtitle: Text(subtitle, style: AppStyles.captionStyle),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppStyles.lightTextColor),
        onTap: onTap,
      ),
    );
  }
}