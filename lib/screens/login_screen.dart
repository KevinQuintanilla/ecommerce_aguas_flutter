import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'registro_screen.dart';
import '../utils/app_styles.dart';
import 'main_app_screen.dart';
import '../widgets/responsive_layout.dart';
import '../utils/constants.dart';
import 'privacy_policy_login_screen.dart';
import 'terms_conditions_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor, // Fondo gris pálido
      body: SafeArea(
        child: Stack( // Usamos Stack para el contenido principal y el footer
          children: [
            // Contenido principal (centrado vertical y horizontalmente)
            Align(
              alignment: Alignment.center,
              child: ResponsiveLayout(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0), // Padding arriba/abajo para no chocar con el footer
                  child: Container(
                    padding: const EdgeInsets.all(AppStyles.largePadding),
                    decoration: AppStyles.cardDecoration, // Tarjeta blanca
                    constraints: const BoxConstraints(maxWidth: 450), // Ancho máximo de la tarjeta
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Que la columna ocupe el mínimo espacio
                      children: [
                        _buildLogo(), // Logo
                        const SizedBox(height: 40),
                        _buildLoginForm(authProvider), // Formulario de login
                        const SizedBox(height: 30),
                        _buildRegisterSection(), // Sección de registro
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Footer (políticas) abajo del todo
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildPolicyFooter(),
            ),
          ],
        ),
      ),
    );
  }

  // --- NUEVA FUNCIÓN PARA EL LOGO (igual a tu imagen) ---
  Widget _buildLogo() {
    return Column(
      children: [
        Image.network(
          '$kApiBaseUrl/images/other/Logotipo.png', // Asume que tienes un logo aquí
          height: 60, // Ajusta la altura si es necesario
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.broken_image, color: AppStyles.errorColor),
        ),
        const SizedBox(height: 20),
        Text(
          'Iniciar Sesión', // Este texto reemplaza "Selecciona cómo quieres iniciar sesión"
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppStyles.darkColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo Email
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Correo electrónico', // Cambiado a "Correo electrónico"
              labelStyle: TextStyle(color: AppStyles.textColor),
              prefixIcon: Icon(Icons.email, color: AppStyles.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppStyles.primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu email';
              }
              if (!value.contains('@')) {
                return 'Ingresa un email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Campo Contraseña
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              labelStyle: TextStyle(color: AppStyles.textColor),
              prefixIcon: Icon(Icons.lock, color: AppStyles.primaryColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: AppStyles.primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppStyles.primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),

          const SizedBox(height: 10),

          // Mensaje de error
          if (authProvider.error.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authProvider.error,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 30),

          // Botón de Login
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: authProvider.cargando
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await authProvider.login(
                          _emailController.text.trim(),
                          _passwordController.text,
                        );

                        if (success && context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const MainAppScreen()),
                            (route) => false,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            AppStyles.successSnackBar('Login exitoso'),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: authProvider.cargando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Iniciar Sesión'),
            ),
          ),
        ],
      ),
    );
  }

  // --- SECCIÓN DE REGISTRO MÁS SIMPLE (solo un botón) ---
  Widget _buildRegisterSection() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 20),
        Text(
          '¿No tienes una cuenta?',
          style: TextStyle(
            fontSize: 16,
            color: AppStyles.textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegistroScreen(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppStyles.primaryColor,
              side: BorderSide(color: AppStyles.primaryColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Crear Cuenta'),
          ),
        ),
      ],
    );
  }

  // --- NUEVA FUNCIÓN PARA EL FOOTER DE POLÍTICAS ---
  Widget _buildPolicyFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      width: double.infinity,
      color: Colors.transparent, // Transparente, se ve el fondo gris
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyLoginScreen()),
              );
            },
            child: Text(
              'Política de privacidad',
              style: TextStyle(color: AppStyles.textColor.withOpacity(0.8), fontSize: 13),
            ),
          ),
          Text(
            ' | ',
            style: TextStyle(color: AppStyles.textColor.withOpacity(0.5), fontSize: 13),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsConditionsLoginScreen()),
              );
            },
            child: Text(
              'Términos del servicio',
              style: TextStyle(color: AppStyles.textColor.withOpacity(0.8), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}