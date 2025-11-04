import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:typed_data'; // Usamos Uint8List para los bytes
import 'package:path/path.dart' as path; 

import '../../providers/categoria_provider.dart';
import '../../services/producto_service.dart';
import '../../utils/app_styles.dart';

class AdminNuevoProductoScreen extends StatefulWidget {
  const AdminNuevoProductoScreen({super.key});

  @override
  State<AdminNuevoProductoScreen> createState() => _AdminNuevoProductoScreenState();
}

class _AdminNuevoProductoScreenState extends State<AdminNuevoProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productoService = ProductoService();
  final _picker = ImagePicker();

  // Controladores
  final _nombreController = TextEditingController();
  final _descController = TextEditingController();
  final _precioController = TextEditingController();
  final _skuController = TextEditingController();

  int? _categoriaSeleccionadaId;
  String? _imagenNombre;
  Uint8List? _imagenBytes;
  String? _tipoCategoria;

  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoriaProvider>(context, listen: false).cargarCategorias();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descController.dispose();
    _precioController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      
      setState(() {
        _imagenBytes = bytes;
        _imagenNombre = pickedFile.name;
      });
    }
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate() || _imagenBytes == null || _tipoCategoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppStyles.errorSnackBar(_imagenBytes == null ? 'Por favor, selecciona una imagen.' : 'Faltan campos requeridos.'),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final datosProducto = {
        "nombre": _nombreController.text,
        "descripcion": _descController.text,
        "precio_actual": double.parse(_precioController.text),
        "categoria_id": _categoriaSeleccionadaId,
        "sku": _skuController.text.isNotEmpty ? _skuController.text : null,
        "tipo_categoria": _tipoCategoria,
      };
      
      final result = await _productoService.crearProducto(
        datosProducto, 
        bytes: _imagenBytes, 
        fileName: _imagenNombre,
      );

      if (mounted) {
        if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              AppStyles.successSnackBar('¡Producto creado exitosamente!'),
            );
            Navigator.of(context).pop();
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
              AppStyles.errorSnackBar(result['error'] ?? 'Error desconocido.'),
            );
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppStyles.errorSnackBar('Error de conexión/subida: $e'),
        );
      }
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Nuevo Producto'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1, // Añadimos elevación
      ),
      backgroundColor: AppStyles.backgroundColor,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.defaultPadding),
          child: Container(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            decoration: AppStyles.cardDecoration, // <-- Tarjeta blanca
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campos de texto y dropdowns
                _buildTextField(_nombreController, 'Nombre del Producto', isRequired: true),
                _buildDropdownCategorias(),
                _buildTextField(_precioController, 'Precio (ej: 350.00)', isRequired: true, isNumber: true),
                _buildTextField(_descController, 'Descripción (Opcional)', maxLines: 4),
                _buildTextField(_skuController, 'SKU (Opcional)'),
                
                // Selectores de archivo
                _buildDropdownTipoCategoria(),
                _buildImagePicker(),

                const SizedBox(height: AppStyles.largePadding),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppStyles.primaryButtonStyle,
                    onPressed: _cargando ? null : _guardarProducto,
                    child: _cargando
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Guardar Producto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES (Sin cambios en funcionalidad) ---
  
  Widget _buildTextField(TextEditingController controller, String label, {bool isRequired = false, bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
      child: TextFormField(
        controller: controller,
        decoration: AppStyles.textFieldDecoration(label),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Este campo es requerido';
          }
          if (isNumber) {
            if (double.tryParse(value!) == null) {
              return 'Debe ser un número válido';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownCategorias() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
      child: Consumer<CategoriaProvider>(
        builder: (context, provider, child) {
          if (provider.cargando) {
            return const Center(child: CircularProgressIndicator());
          }
          return DropdownButtonFormField<int>(
            value: _categoriaSeleccionadaId,
            decoration: AppStyles.textFieldDecoration('Categoría'),
            hint: const Text('Selecciona una categoría'),
            items: provider.categorias.map((categoria) {
              return DropdownMenuItem<int>(
                value: categoria.categoriaId,
                child: Text(categoria.nombre),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _categoriaSeleccionadaId = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Debes seleccionar una categoría';
              }
              return null;
            },
          );
        },
      ),
    );
  }

  // 1. Dropdown para tipo de categoría (agua/merch)
  Widget _buildDropdownTipoCategoria() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
      child: DropdownButtonFormField<String>(
        value: _tipoCategoria,
        decoration: AppStyles.textFieldDecoration('Tipo de Producto (Carpeta)'),
        hint: const Text('Selecciona Agua o Merchandise'),
        items: const [
          DropdownMenuItem(value: 'agua', child: Text('Agua')),
          DropdownMenuItem(value: 'merch', child: Text('Merchandise')),
        ],
        onChanged: (value) {
          setState(() {
            _tipoCategoria = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Debes seleccionar el tipo de producto';
          }
          return null;
        },
      ),
    );
  }

  // 2. Selector de Imagen
  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: _seleccionarImagen,
            icon: const Icon(Icons.image),
            label: const Text('Seleccionar Imagen del Producto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.infoColor, // <-- Color azul info
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (_imagenNombre != null) // Muestra el nombre
            Text(
              'Archivo seleccionado: $_imagenNombre', 
              style: AppStyles.captionStyle,
            )
          else
            const Text(
              'Ningún archivo seleccionado. (Requerido)',
              style: TextStyle(color: AppStyles.errorColor),
            ),
        ],
      ),
    );
  }
}