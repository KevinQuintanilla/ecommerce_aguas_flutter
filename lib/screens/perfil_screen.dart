import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'historial_pedidos_screen.dart';
import 'direcciones_screen.dart';
import 'configuracion_screen.dart';
import '../widgets/responsive_layout.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

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
        'icon': Icons.logout,
        'title': 'Cerrar Sesión',
        'subtitle': 'Salir de tu cuenta',
        'action': 'logout',
        'isLogout': true
      },
    ];

    return Container(
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: options.map((option) {
          return ListTile(
            leading: Icon(
              option['icon'] as IconData,
              color: (option['isLogout'] as bool?) == true
                  ? AppStyles.errorColor
                  : AppStyles.primaryColor,
            ),
            title: Text(
              option['title'] as String,
              style: AppStyles.bodyTextStyle.copyWith(
                color: (option['isLogout'] as bool?) == true
                    ? AppStyles.errorColor
                    : AppStyles.textColor,
              ),
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

  // void _mostrarProximamente(BuildContext context, String feature) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Próximamente'),
  //       content:
  //           Text('$feature estará disponible en una próxima actualización.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildLoginPrompt(BuildContext context) {
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
              // FORZAR LA NAVEGACIÓN EXPLÍCITA AL LOGIN
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
