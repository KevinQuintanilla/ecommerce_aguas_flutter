import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../providers/auth_provider.dart';
import '../utils/app_styles.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/web_header.dart';
import '../widgets/web_footer.dart';

// Importamos las pantallas a las que vamos a navegar
import 'historial_pedidos_screen.dart';
import 'direcciones_screen.dart';
import 'configuracion_screen.dart';
import 'login_screen.dart';
import 'main_app_screen.dart';

class WebPerfilScreen extends StatelessWidget {
  const WebPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos el AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor, // Fondo gris pálido
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 2. Muestra el Header
            const WebHeader(selectedIndex: 3),

            // 3. Contenido principal centrado
            ResponsiveLayout(
              maxWidth: 1000,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppStyles.largePadding,
                    horizontal: AppStyles.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la página
                    Text(
                      'Mi Cuenta',
                      style: AppStyles.headingStyle.copyWith(
                        fontSize: 36,
                        color: AppStyles.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppStyles.mediumPadding),

                    // 4. Lógica de autenticación (igual que en mobile)
                    if (authProvider.estaAutenticado)
                      _buildWebProfileContent(context, authProvider)
                    else
                      _buildWebLoginPrompt(context),
                  ],
                ),
              ),
            ),

            // 5. Muestra el Footer
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS PARA EL USUARIO AUTENTICADO ---

  Widget _buildWebProfileContent(
      BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tarjeta de información del usuario (copiada de mobile)
        _buildUserProfile(authProvider.usuario!),
        const SizedBox(height: AppStyles.largePadding),

        // Título de la sección de opciones
        Text(
          'Panel de Control',
          style: AppStyles.subheadingStyle.copyWith(
              color: AppStyles.textColor, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppStyles.defaultPadding),

        // Opciones en un Row de 3 tarjetas
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildOptionCard(
                context: context,
                icon: Icons.history,
                title: 'Mis Pedidos',
                subtitle: 'Historial de compras',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistorialPedidosScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppStyles.defaultPadding),
            Expanded(
              child: _buildOptionCard(
                context: context,
                icon: Icons.location_on,
                title: 'Direcciones',
                subtitle: 'Gestionar envíos',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DireccionesScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppStyles.defaultPadding),
            Expanded(
              child: _buildOptionCard(
                context: context,
                icon: Icons.settings,
                title: 'Configuración',
                subtitle: 'Editar perfil y contraseña',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConfiguracionScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.largePadding),
        
        // Botón de Cerrar Sesión
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            onPressed: () {
              _mostrarDialogoCerrarSesion(authProvider, context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppStyles.errorColor,
              side: const BorderSide(color: AppStyles.errorColor),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Tarjeta de información del usuario (casi idéntica a la de mobile)
  Widget _buildUserProfile(Usuario usuario) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.mediumPadding),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppStyles.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nombreCompleto,
                  style: AppStyles.headingStyle,
                ),
                const SizedBox(height: 4),
                Text(usuario.email, style: AppStyles.bodyTextStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // El nuevo widget de tarjeta para el layout web
  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
        side: const BorderSide(color: AppStyles.borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
        hoverColor: AppStyles.primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: AppStyles.primaryColor),
              const SizedBox(height: AppStyles.defaultPadding),
              Text(title, style: AppStyles.subheadingStyle),
              const SizedBox(height: AppStyles.smallPadding),
              Text(subtitle, style: AppStyles.captionStyle),
            ],
          ),
        ),
      ),
    );
  }

  // Diálogo de cerrar sesión (copiado de mobile)
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
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainAppScreen()),
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

  // --- WIDGET PARA USUARIO NO AUTENTICADO ---

  // (Copiado directamente de tu mobile_perfil_screen)
  Widget _buildWebLoginPrompt(BuildContext context) {
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
            'Accede a tu cuenta para ver tus pedidos y direcciones',
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
            style: AppStyles.primaryButtonStyle.copyWith(
              // Quitamos el ancho infinito para que se ajuste al texto
              minimumSize: MaterialStateProperty.all(const Size(150, 50)),
            ),
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }
}