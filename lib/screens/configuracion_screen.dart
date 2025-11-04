import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_styles.dart';
import '../widgets/responsive_layout.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
      ),
      backgroundColor: AppStyles.backgroundColor,
      body: ResponsiveLayout(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          children: [
            // Tarjeta 1: Formulario de Datos Personales
            _buildDatosPersonalesCard(),
            
            const SizedBox(height: AppStyles.largePadding),

            // Tarjeta 2: Formulario de Cambio de Contraseña
            _buildPasswordCard(),
          ],
        ),
      ),
      )
    );
  }

  // --- WIDGET PARA DATOS PERSONALES ---
  Widget _buildDatosPersonalesCard() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos Personales',
            style: AppStyles.headingStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Actualiza tu nombre, apellido y teléfono.',
            style: AppStyles.captionStyle,
          ),
          const Divider(height: 24),
          _PerfilForm(), // Usamos un widget con estado interno
        ],
      ),
    );
  }

  // --- WIDGET PARA CAMBIAR CONTRASEÑA ---
  Widget _buildPasswordCard() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cambiar Contraseña',
            style: AppStyles.headingStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa tu contraseña actual y la nueva.',
            style: AppStyles.captionStyle,
          ),
          const Divider(height: 24),
          _PasswordForm(), // Usamos un widget con estado interno
        ],
      ),
    );
  }
}


// --- FORMULARIO INTERNO PARA PERFIL ---
class _PerfilForm extends StatefulWidget {
  @override
  __PerfilFormState createState() => __PerfilFormState();
}

class __PerfilFormState extends State<_PerfilForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _telefonoController;

  @override
  void initState() {
    super.initState();
    final usuario = Provider.of<AuthProvider>(context, listen: false).usuario;
    _nombreController = TextEditingController(text: usuario?.nombre ?? '');
    _apellidoController = TextEditingController(text: usuario?.apellido ?? '');
    _telefonoController = TextEditingController(text: usuario?.telefono ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final resultado = await authProvider.actualizarPerfil(
      _nombreController.text.trim(),
      _apellidoController.text.trim(),
      _telefonoController.text.trim(),
    );

    if (mounted) {
      if (resultado['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppStyles.successSnackBar('¡Perfil actualizado con éxito!'),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppStyles.errorSnackBar('Error: ${resultado['error']}'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nombreController,
            decoration: AppStyles.textFieldDecoration('Nombre'),
            validator: (val) => val!.isEmpty ? 'Ingresa tu nombre' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _apellidoController,
            decoration: AppStyles.textFieldDecoration('Apellido'),
            validator: (val) => val!.isEmpty ? 'Ingresa tu apellido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _telefonoController,
            decoration: AppStyles.textFieldDecoration('Teléfono (Opcional)'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppStyles.primaryButtonStyle,
              onPressed: authProvider.cargando ? null : _submitForm,
              child: authProvider.cargando
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Guardar Cambios'),
            ),
          ),
        ],
      ),
    );
  }
}


// --- FORMULARIO INTERNO PARA CONTRASEÑA ---
class _PasswordForm extends StatefulWidget {
  @override
  __PasswordFormState createState() => __PasswordFormState();
}

class __PasswordFormState extends State<_PasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _actualController = TextEditingController();
  final _nuevaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _obscureActual = true;
  bool _obscureNueva = true;

  @override
  void dispose() {
    _actualController.dispose();
    _nuevaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final resultado = await authProvider.cambiarPassword(
      _actualController.text,
      _nuevaController.text,
    );

    if (mounted) {
      if (resultado['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppStyles.successSnackBar('¡Contraseña actualizada!'),
        );
        _formKey.currentState?.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppStyles.errorSnackBar('Error: ${resultado['error']}'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _actualController,
            obscureText: _obscureActual,
            decoration: AppStyles.textFieldDecoration('Contraseña Actual').copyWith(
              suffixIcon: IconButton(
                icon: Icon(_obscureActual ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureActual = !_obscureActual),
              ),
            ),
            validator: (val) => val!.isEmpty ? 'Ingresa tu contraseña actual' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nuevaController,
            obscureText: _obscureNueva,
            decoration: AppStyles.textFieldDecoration('Nueva Contraseña').copyWith(
              suffixIcon: IconButton(
                icon: Icon(_obscureNueva ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureNueva = !_obscureNueva),
              ),
            ),
            validator: (val) {
              if (val!.isEmpty) return 'Ingresa una nueva contraseña';
              if (val.length < 6) return 'Debe tener al menos 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmarController,
            obscureText: _obscureNueva,
            decoration: AppStyles.textFieldDecoration('Confirmar Nueva Contraseña'),
            validator: (val) {
              if (val != _nuevaController.text) return 'Las contraseñas no coinciden';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppStyles.primaryButtonStyle,
              onPressed: authProvider.cargando ? null : _submitForm,
              child: authProvider.cargando
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Cambiar Contraseña'),
            ),
          ),
        ],
      ),
    );
  }
}