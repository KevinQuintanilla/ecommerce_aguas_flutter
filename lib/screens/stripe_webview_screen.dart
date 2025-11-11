import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../providers/carrito_provider.dart';
import 'confirmacion_pedido_screen.dart';
import '../models/pedido.dart';
import '../utils/constants.dart'; // Importamos tus constantes

class StripeWebviewScreen extends StatefulWidget {
  final Pedido pedido;
  final String urlPago;

  const StripeWebviewScreen({
    Key? key,
    required this.pedido,
    required this.urlPago,
  }) : super(key: key);

  @override
  State<StripeWebviewScreen> createState() => _StripeWebviewScreenState();
}

class _StripeWebviewScreenState extends State<StripeWebviewScreen> {
  InAppWebViewController? _webViewController;
  bool _cargando = true;

  // ¡CAMBIADO! Usamos tu constante kApiBaseUrl
  // Asegúrate de que el puerto (3000) coincida con tu backend
  final String _successUrl = '${kApiBaseUrl}/pago-exitoso.html';
  final String _cancelUrl = '${kApiBaseUrl}/pago-cancelado.html';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Pago'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _mostrarDialogoCancelar(),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            // --- ¡SINTAXIS v6! ---
            // 'initialUrlRequest' ahora usa 'WebUri()'
            initialUrlRequest: URLRequest(url: WebUri(widget.urlPago)),
            
            // 'initialOptions' ahora es 'initialSettings'
            // 'InAppWebViewGroupOptions' ahora es 'InAppWebViewSettings'
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              javaScriptCanOpenWindowsAutomatically: true,
            ),
            // --- FIN SINTAXIS v6 ---

            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() { _cargando = true; });

              // La lógica de detección de URL sigue igual
              // Comparamos las URLs
              if (url.toString() == _successUrl) {
                _pagoCompletado(context);
                controller.stopLoading();
              } else if (url.toString() == _cancelUrl) {
                _pagoCancelado(context);
                controller.stopLoading();
              }
            },
            onLoadStop: (controller, url) {
              setState(() { _cargando = false; });
            },
            onLoadError: (controller, request, code, message) {
               setState(() { _cargando = false; });
               // Manejar error si es necesario
               print('Error al cargar WebView: $message');
            },
            onReceivedError: (controller, request, error) {
              setState(() { _cargando = false; });
              // Manejar error si es necesario
              print('Error recibido: ${error.description}');
            },
          ),
          if (_cargando)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _pagoCompletado(BuildContext context) {
    // 1. Limpiar el carrito
    Provider.of<CarritoProvider>(context, listen: false).limpiarCarrito();

    // 2. Navegar a la pantalla de confirmación, reemplazando esta
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => ConfirmacionPedidoScreen(
          pedido: widget.pedido, // Le pasamos el pedido pendiente
        ),
      ),
      (route) => route.isFirst, // Limpia la pila de navegación
    );
  }

  void _pagoCancelado(BuildContext context) {
    // El usuario canceló
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pago cancelado.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _mostrarDialogoCancelar() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Cancelar pago?'),
          content: const SingleChildScrollView(
            child: Text('¿Estás seguro de que deseas cancelar el proceso de pago?'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Continuar Pagando'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sí, cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.of(context).pop(); // Cierra el WebView
              },
            ),
          ],
        );
      },
    );
  }
}