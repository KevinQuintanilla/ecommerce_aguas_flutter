import 'package:flutter/material.dart';
import 'web_header.dart';
import 'web_footer.dart';
import '../utils/app_styles.dart';

class WebPageLayout extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final Color backgroundColor;

  const WebPageLayout({
    super.key,
    required this.body,
    required this.selectedIndex,
    this.backgroundColor = Colors.white, // Por defecto es blanco
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              // 1. Forzamos la altura mínima a ser la altura de la pantalla
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                // 2. Esto empuja el Header/Body hacia arriba y el Footer hacia abajo
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 3. Grupo de contenido (Header + Body)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WebHeader(selectedIndex: selectedIndex),
                      body, // Aquí va el contenido de tu página
                    ],
                  ),
                  
                  // 4. Footer (siempre al fondo)
                  const WebFooter(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}