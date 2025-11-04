import 'package:flutter/material.dart';
import 'web_page_layout.dart'; 
import 'responsive_layout.dart';
import '../utils/app_styles.dart';

class StaticPageLayout extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<Widget> children;

  const StaticPageLayout({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    // Usa el WebPageLayout para obtener el Header y el Footer "pegajoso"
    return WebPageLayout(
      selectedIndex: -1, // Ninguna pestaña principal seleccionada
      backgroundColor: Colors.white,
      body: ResponsiveLayout(
        maxWidth: 900, // Ancho para texto
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                title,
                style: AppStyles.headingStyle.copyWith(fontSize: 36, color: AppStyles.primaryColor),
              ),
              const SizedBox(height: 16),
              // Fecha
              Text(
                "Última actualización: $lastUpdated",
                style: AppStyles.bodyTextStyle.copyWith(fontSize: 14, color: AppStyles.lightTextColor, fontStyle: FontStyle.italic),
              ),
              const Divider(height: 40),
              // Contenido
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

// Widgets de ayuda para el texto legal
class LegalHeading extends StatelessWidget {
  final String text;
  const LegalHeading({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        text,
        style: AppStyles.headingStyle.copyWith(fontSize: 24, color: AppStyles.primaryColor),
      ),
    );
  }
}

class LegalParagraph extends StatelessWidget {
  final String text;
  const LegalParagraph({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: AppStyles.bodyTextStyle.copyWith(fontSize: 16, height: 1.6),
      ),
    );
  }
}