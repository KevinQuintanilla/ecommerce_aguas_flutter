import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'historial_pedidos_screen.dart';
import 'direcciones_screen.dart';
import 'configuracion_screen.dart';
import '../widgets/responsive_layout.dart';

// --- CAMBIO AQUÍ ---
// Estas son las importaciones correctas
import 'mobile_about_us_screen.dart'; 
import 'mobile_find_us_screen.dart';
// --- FIN DEL CAMBIO ---

import 'admin/admin_dashboard_screen.dart';

class MobilePerfilScreen extends StatelessWidget {
  const MobilePerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
      ),
      backgroundColor: AppStyles.backgroundColor, // <-- Fondo gris
      body: ResponsiveLayout( 
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(AppStyles.defaultPadding),
          child: Column(
            children: [
              if (authProvider.estaAutenticado) ...[
                _buildUserProfile(authProvider),
                const SizedBox(height: AppStyles.largePadding),
                _buildProfileOptions(authProvider, context),
              ] else ...[
                _buildLoginPrompt(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.mediumPadding),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppStyles.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.usuario!.nombreCompleto,
                  style: AppStyles.headingStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.usuario!.email,
                  style: AppStyles.bodyTextStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  'Cliente desde 2024',
                  style: AppStyles.captionStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(AuthProvider authProvider, BuildContext context) {
    
    // --- LIMPIEZA: Quitamos el "Encuéntranos" duplicado ---
    final options = [
      {
        'icon': Icons.history,
        'title': 'Mis Pedidos',
        'subtitle': 'Historial de compras',
        'action': 'pedidos'
      },
      {
        'icon': Icons.location_on,
        'title': 'Direcciones',
        'subtitle': 'Gestionar envíos',
        'action': 'direcciones'
      },
      {
        'icon': Icons.settings,
        'title': 'Configuración',
        'subtitle': 'Preferencias',
        'action': 'configuracion'
      },
      {
        'icon': Icons.info_outline,
        'title': 'Acerca de Nosotros',
        'subtitle': 'Nuestra historia',
        'action': 'about_us'
      },
      {
        'icon': Icons.map_outlined,
        'title': 'Encuéntranos',
        'subtitle': 'Nuestros distribuidores',
        'action': 'find_us'
      },
      // (El duplicado se eliminó)
    ];
    // --- FIN DE LA LIMPIEZA ---

    return Container(
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          // Mapea las opciones normales
          ...options.map((option) {
            return ListTile(
              leading: Icon(
                option['icon'] as IconData,
                color: AppStyles.primaryColor,
              ),
              title: Text(
                option['title'] as String,
                style: AppStyles.bodyTextStyle,
              ),
              subtitle: Text(
                option['subtitle'] as String,
                style: AppStyles.captionStyle,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _handleOptionTap(
                    option['action'] as String, authProvider, context);
              },
            );
          }).toList(),
          
          // Botón de Admin (si es admin)
          if (authProvider.usuario != null &&
              authProvider.usuario!.tipoUsuario != 'cliente')
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: AppStyles.accentColor),
              title: Text(
                'Panel de Administrador',
                style: AppStyles.bodyTextStyle.copyWith(color: AppStyles.accentColor, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Gestionar pedidos y productos',
                style: AppStyles.captionStyle,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                );
              },
            ),

          // Botón de Cerrar Sesión (siempre al final)
          ListTile(
            leading: const Icon(Icons.logout, color: AppStyles.errorColor),
            title: Text(
              'Cerrar Sesión',
              style: AppStyles.bodyTextStyle.copyWith(color: AppStyles.errorColor),
            ),
            subtitle: Text(
              'Salir de tu cuenta',
              style: AppStyles.captionStyle,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _handleOptionTap('logout', authProvider, context);
            },
          ),
        ],
      ),
    );
  }

  void _handleOptionTap(
      String action, AuthProvider authProvider, BuildContext context) {
    switch (action) {
      case 'pedidos':
        _navegarAHistorialPedidos(context);
        break;
      case 'direcciones':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DireccionesScreen()),
        );
        break;
      case 'configuracion':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ConfiguracionScreen()),
        );
        break;
        
      // --- CAMBIO AQUÍ ---
      // Ahora apuntan a las pantallas móviles correctas
      case 'about_us':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MobileAboutUsScreen()),
        );
        break;
      case 'find_us':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MobileFindUsScreen()),
        );
        break;
      // --- FIN DEL CAMBIO ---
        
      case 'logout':
        _mostrarDialogoCerrarSesion(authProvider, context);
        break;
    }
  }

  void _navegarAHistorialPedidos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistorialPedidosScreen(),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    // ... (Esta función queda igual) ...
    return Container(
      padding: const EdgeInsets.all(AppStyles.largePadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          const Icon(
            Icons.person_outline,
            size: 80,
            color: AppStyles.lightTextColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Inicia sesión',
            style: AppStyles.headingStyle,
          ),
          const SizedBox(height: 10),
          Text(
            'Accede a tu cuenta para ver tus pedidos y favoritos',
            style: AppStyles.bodyTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            style: AppStyles.primaryButtonStyle,
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoCerrarSesion(
      AuthProvider authProvider, BuildContext context) {
    // ... (Esta función queda igual) ...
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}