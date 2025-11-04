import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../utils/app_styles.dart';
import 'main_app_screen.dart';
import '../widgets/responsive_layout.dart';
import '../utils/constants.dart'; // Asegúrate de tener kApiBaseUrl aquí para el logo

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0), // Padding arriba/abajo
                  child: Container(
                    padding: const EdgeInsets.all(AppStyles.largePadding),
                    decoration: AppStyles.cardDecoration, // Tarjeta blanca
                    constraints: const BoxConstraints(maxWidth: 450), // Ancho máximo de la tarjeta
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Que la columna ocupe el mínimo espacio
                      children: [
                        _buildLogo(), // Logo
                        const SizedBox(height: 40),
                        _buildRegisterForm(authProvider), // Formulario de registro
                        const SizedBox(height: 20),
                        _buildLoginLink(), // Enlace a Login
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

  // --- NUEVA FUNCIÓN PARA EL LOGO (igual que en LoginScreen) ---
  Widget _buildLogo() {
    return Column(
      children: [
        Image.network(
          '$kApiBaseUrl/images/other/Logotipo.png', // Tu logo
          height: 60, // Ajusta la altura si es necesario
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.broken_image, color: AppStyles.errorColor),
        ),
        const SizedBox(height: 20),
        Text(
          'Crear Cuenta', // Título "Crear Cuenta"
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppStyles.darkColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Nombre y Apellido
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: AppStyles.textColor),
                    prefixIcon: Icon(Icons.person, color: AppStyles.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu nombre';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _apellidoController,
                  decoration: InputDecoration(
                    labelText: 'Apellido',
                    labelStyle: TextStyle(color: AppStyles.textColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu apellido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: AppStyles.textColor),
              prefixIcon: Icon(Icons.email, color: AppStyles.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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

          // Teléfono
          TextFormField(
            controller: _telefonoController,
            decoration: InputDecoration(
              labelText: 'Teléfono (opcional)',
              labelStyle: TextStyle(color: AppStyles.textColor),
              prefixIcon: Icon(Icons.phone, color: AppStyles.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),

          // Contraseña
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
          const SizedBox(height: 20),

          // Confirmar Contraseña
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar Contraseña',
              labelStyle: TextStyle(color: AppStyles.textColor),
              prefixIcon: Icon(Icons.lock_outline, color: AppStyles.primaryColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppStyles.primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Mensaje de error
          if (authProvider.error.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
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

          // Botón de Registro
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: authProvider.cargando
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await authProvider.register(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                          nombre: _nombreController.text.trim(),
                          apellido: _apellidoController.text.trim(),
                          telefono: _telefonoController.text.trim().isEmpty
                              ? null
                              : _telefonoController.text.trim(),
                        );

                        if (success && context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const MainAppScreen()),
                            (route) => false,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            AppStyles.successSnackBar('Registro exitoso'),
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
                  : const Text('Crear Cuenta'),
            ),
          ),
        ],
      ),
    );
  }

  // --- NUEVA FUNCIÓN PARA EL ENLACE A LOGIN ---
  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
      child: Text(
        '¿Ya tienes cuenta? Inicia Sesión',
        style: TextStyle(
          color: AppStyles.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // --- FUNCIÓN PARA EL FOOTER DE POLÍTICAS (igual que en LoginScreen) ---
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
              // TODO: Implementar navegación a Política de privacidad
              print('Navegar a Política de privacidad');
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
              print('Navegar a Términos del servicio');
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
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }
}