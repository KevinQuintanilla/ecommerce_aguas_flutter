import 'package:flutter/material.dart';

/// Este widget envuelve el contenido de una pantalla.
/// En pantallas pequeñas (móvil), no hace nada.
/// En pantallas grandes (tablet/web), centra el contenido y
/// le da un ancho máximo para que no se "alargue".
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  
  // Puedes ajustar este valor. 900 es bueno para formularios y listas.
  // 1200 es bueno para dashboards o catálogos más anchos.
  final double maxWidth;

  const ResponsiveLayout({
    super.key, 
    required this.child,
    this.maxWidth = 1000.0,
  });

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder nos da el ancho real de la pantalla
    return LayoutBuilder(
      builder: (context, constraints) {
        
        // Si la pantalla es más ancha que nuestro máximo...
        if (constraints.maxWidth > maxWidth) {
          // ...centramos el contenido.
          return Center(
            child: ConstrainedBox(
              // Limitamos el ancho del contenido
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          );
        } else {
          return child;
        }
      },
    );
  }
}