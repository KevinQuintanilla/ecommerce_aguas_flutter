import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../providers/auth_provider.dart';
import '../utils/app_styles.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/web_page_layout.dart';
import 'historial_pedidos_screen.dart';
import 'direcciones_screen.dart';
import 'configuracion_screen.dart';
import 'login_screen.dart';
import 'main_app_screen.dart';

// --- 1. AÑADE LA IMPORTACIÓN DE LA PANTALLA DE ADMIN ---
import 'admin/admin_dashboard_screen.dart';

class WebPerfilScreen extends StatelessWidget {
  const WebPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return WebPageLayout(
      selectedIndex: 3,
      backgroundColor: AppStyles.backgroundColor, 
      body: ResponsiveLayout(
        maxWidth: 1000,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: AppStyles.largePadding,
              horizontal: AppStyles.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi Cuenta',
                style: AppStyles.headingStyle.copyWith(
                  fontSize: 36,
                  color: AppStyles.primaryColor,
                ),
              ),
              const SizedBox(height: AppStyles.mediumPadding),
              if (authProvider.estaAutenticado)
                _buildWebProfileContent(context, authProvider)
              else
                _buildWebLoginPrompt(context),
            ],
          ),
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
        // Tarjeta de información del usuario
        _buildUserProfile(authProvider.usuario!),
        const SizedBox(height: AppStyles.largePadding),

        // Título de la sección de opciones
        Text(
          'Panel de Control',
          style: AppStyles.subheadingStyle.copyWith(
              color: AppStyles.textColor, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppStyles.defaultPadding),

        // Opciones en un Row
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

            // --- 2. AÑADE LA TARJETA DE ADMIN CONDICIONAL ---
            if (authProvider.usuario != null &&
                authProvider.usuario!.tipoUsuario != 'cliente') ...[
              const SizedBox(width: AppStyles.defaultPadding),
              Expanded(
                child: _buildOptionCard(
                  context: context,
                  icon: Icons.admin_panel_settings,
                  title: 'Admin Panel',
                  subtitle: 'Gestionar la tienda',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                    );
                  },
                  iconColor: AppStyles.accentColor, // <-- Color de acento
                ),
              ),
            ]
            // --- FIN DE LA ADICIÓN ---
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

  // Tarjeta de información del usuario
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

  // --- 3. MODIFICA LA TARJETA DE OPCIÓN (para aceptar color) ---
  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor, // <-- AÑADE ESTE PARÁMETRO
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
              Icon(
                icon,
                size: 32,
                color: iconColor ?? AppStyles.primaryColor, // <-- USA EL PARÁMETRO
              ),
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

  // Diálogo de cerrar sesión
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
              minimumSize: MaterialStateProperty.all(const Size(150, 50)),
            ),
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }
}