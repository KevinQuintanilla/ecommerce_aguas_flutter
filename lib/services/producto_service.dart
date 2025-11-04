import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/producto.dart';
import '../models/categoria.dart';
import '../utils/constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';


class ProductoService {
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  // static const String baseUrl = 'http://localhost:3000/api';
  static const String baseUrl = kApiBaseUrl + '/api';

  Future<List<Producto>> obtenerProductos({int? categoriaId}) async {
    try {
      // Construimos la URL
      String url = '$baseUrl/productos';
      if (categoriaId != null) {
        url += '?categoria_id=$categoriaId'; // <-- Añadimos el filtro a la URL
      }

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Producto.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener la lista de categorías para los filtros
  Future<List<Categoria>> obtenerCategorias() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categorias'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Categoria.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  // Obtiene un solo producto por su ID (incluyendo sus reseñas)
  Future<Producto> obtenerProductoPorId(int productoId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/productos/$productoId'));
      
      if (response.statusCode == 200) {
        return Producto.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar el producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  // Obtener productos destacados para el carrusel
  Future<List<Producto>> obtenerProductosDestacados() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/productos/destacados'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Producto.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos destacados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  // Enviar una nueva reseña
  Future<Map<String, dynamic>> enviarResena({
    required int productoId,
    required int clienteId,
    required int pedidoId,
    required int puntuacion,
    String? comentario,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resenas'), // Llama al nuevo endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'producto_id': productoId,
          'cliente_id': clienteId,
          'pedido_id': pedidoId,
          'puntuacion': puntuacion,
          'comentario': comentario,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 201) { // 201 = Creado
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
  // INICIO DE FUNCIÓN DE ADMIN
  
  /// (ADMIN) Crea un nuevo producto y sube la imagen.
    Future<Map<String, dynamic>> crearProducto(Map<String, dynamic> datosProducto, {Uint8List? bytes, String? fileName}) async {
    try {
        // 1. Crea la solicitud Multipart
        var request = http.MultipartRequest(
            'POST',
            Uri.parse('$baseUrl/productos/nuevo'),
        );
        
        // 2. Añade los campos de texto
        datosProducto.forEach((key, value) {
            request.fields[key] = value.toString();
        });

        // 3. Añade el archivo de imagen (desde Bytes)
        if (bytes != null && fileName != null) {
            final fileExtension = path.extension(fileName);
            
            String mimeType;
            if (fileExtension.length > 1) { 
                mimeType = fileExtension.substring(1).toLowerCase(); 
            } else {
                mimeType = 'jpeg'; // Fallback seguro
            }
            
            request.files.add(
                http.MultipartFile.fromBytes( // <-- USAMOS FROMBYTES!
                    'imagen',
                    bytes,
                    filename: fileName, // <-- Añadimos el nombre del archivo
                    contentType: MediaType('image', mimeType), 
                ),
            );
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201) { 
            return {'success': true, 'message': 'Producto creado exitosamente'};
        } else {
            final error = json.decode(response.body);
            return {'success': false, 'error': error['error'] ?? 'Error desconocido al crear producto'};
        }
    } catch (e) {
        return {'success': false, 'error': 'Error de subida: ${e.toString()}'}; 
    }
  }
}