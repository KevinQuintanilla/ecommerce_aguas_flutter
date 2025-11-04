import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/direccion_envio.dart';
import '../providers/auth_provider.dart';
import '../providers/direccion_provider.dart';
import '../utils/app_styles.dart';
import '../widgets/responsive_layout.dart';

class FormDireccionScreen extends StatefulWidget {
  // Si esta variable no es null, estamos en modo "Editar".
  // Si es null, estamos en modo "Agregar".
  final DireccionEnvio? direccion;

  // Hacemos que el constructor sea 'const'
  const FormDireccionScreen({super.key, this.direccion});

  @override
  State<FormDireccionScreen> createState() => _FormDireccionScreenState();
}

class _FormDireccionScreenState extends State<FormDireccionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargando = false;

  // Controladores para todos los campos del formulario
  final _calleController = TextEditingController();
  final _numExtController = TextEditingController();
  final _numIntController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cpController = TextEditingController();
  final _referenciasController = TextEditingController();

  // Getter para saber si estamos en modo edición
  bool get _modoEdicion => widget.direccion != null;

  @override
  void initState() {
    super.initState();
    if (_modoEdicion) {
      // Si estamos editando, llenamos los campos con los datos existentes
      final dir = widget.direccion!;
      _calleController.text = dir.calle;
      _numExtController.text = dir.numeroExterior ?? '';
      _numIntController.text = dir.numeroInterior ?? '';
      _coloniaController.text = dir.colonia ?? '';
      _ciudadController.text = dir.ciudad;
      _estadoController.text = dir.estado;
      _cpController.text = dir.codigoPostal;
      _referenciasController.text = dir.referencias ?? '';
    }
  }

  @override
  void dispose() {
    // Limpiamos los controladores al salir de la pantalla
    _calleController.dispose();
    _numExtController.dispose();
    _numIntController.dispose();
    _coloniaController.dispose();
    _ciudadController.dispose();
    _estadoController.dispose();
    _cpController.dispose();
    _referenciasController.dispose();
    super.dispose();
  }

  Future<void> _guardarDireccion() async {
    if (!_formKey.currentState!.validate()) {
      return; // Validación fallida, no continuar
    }

    setState(() { _cargando = true; });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final direccionProvider = Provider.of<DireccionProvider>(context, listen: false);

    if (!authProvider.estaAutenticado || authProvider.usuario?.clienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppStyles.errorSnackBar('Error: Usuario no autenticado.'),
      );
      setState(() { _cargando = false; });
      return;
    }

    final int clienteId = authProvider.usuario!.clienteId!;

    // Creamos el mapa de datos (JSON) desde los controladores
    final Map<String, dynamic> data = {
      'cliente_id': clienteId,
      'calle': _calleController.text.trim(),
      'numero_exterior': _numExtController.text.trim(),
      'numero_interior': _numIntController.text.trim(),
      'colonia': _coloniaController.text.trim(),
      'ciudad': _ciudadController.text.trim(),
      'estado': _estadoController.text.trim(),
      'codigo_postal': _cpController.text.trim(),
      'referencias': _referenciasController.text.trim(),
      'tipo': 'envío', // Por defecto 'envío', puedes cambiarlo por un Dropdown si quieres
      'pais': 'México', // Por defecto 'México'
    };

    bool success = false;
    try {
      if (_modoEdicion) {
        // MODO EDITAR: Llamamos a actualizar
        success = await direccionProvider.actualizarDireccion(
          widget.direccion!.direccionId, 
          data
        );
      } else {
        // MODO AGREGAR: Llamamos a agregar
        success = await direccionProvider.agregarDireccion(data);
      }
    } catch (e) {
      print('Error al guardar: $e');
    }

    setState(() { _cargando = false; });

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppStyles.successSnackBar('¡Dirección guardada exitosamente!'),
      );
      Navigator.of(context).pop(); // Regresamos a la lista de direcciones
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppStyles.errorSnackBar('Error al guardar: ${direccionProvider.error}'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modoEdicion ? 'Editar Dirección' : 'Nueva Dirección'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
      ),
      body: ResponsiveLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextFormField(
                controller: _calleController,
                label: 'Calle',
                icon: Icons.signpost,
                validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _numExtController,
                      label: 'Num. Exterior',
                      icon: Icons.pin,
                      validator: (val) => val!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _numIntController,
                      label: 'Num. Interior (Opc)',
                      icon: Icons.apartment,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _coloniaController,
                label: 'Colonia',
                icon: Icons.holiday_village,
                validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _cpController,
                      label: 'C.P.',
                      icon: Icons.local_post_office,
                      keyboardType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _ciudadController,
                      label: 'Ciudad',
                      icon: Icons.location_city,
                      validator: (val) => val!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _estadoController,
                label: 'Estado',
                icon: Icons.map,
                validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _referenciasController,
                label: 'Referencias (Opcional)',
                icon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: AppStyles.largePadding),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppStyles.primaryButtonStyle,
                  onPressed: _cargando ? null : _guardarDireccion,
                  child: _cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_modoEdicion ? 'Actualizar Dirección' : 'Guardar Dirección'),
                ),
              ),
            ],
          ),
        ),
      ),
      )
    );
  }

  // Helper widget para crear los campos de texto
  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: AppStyles.textFieldDecoration(label).copyWith(
        prefixIcon: Icon(icon, color: AppStyles.primaryColor),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.words,
    );
  }
}