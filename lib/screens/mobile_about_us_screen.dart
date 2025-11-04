import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class MobileAboutUsScreen extends StatelessWidget {
  const MobileAboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor, // Fondo gris
      appBar: AppBar(
        title: const Text('Acerca de Nosotros'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          children: [
            // Tarjeta 1: Nuestra Historia
            Container(
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              decoration: AppStyles.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nuestra Historia de Pureza", style: AppStyles.headingStyle.copyWith(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text("Más de 80 años llevando bienestar a los hogares de México.", style: AppStyles.bodyTextStyle.copyWith(fontSize: 16, color: AppStyles.lightTextColor)),
                  const Divider(height: 24),
                  Text(
                    "Fundada en 1937, Aguas de Lourdes nació con un simple pero poderoso objetivo: ofrecer el agua más pura y confiable a nuestra comunidad. Desde nuestra primera planta embotelladora, hemos mantenido un compromiso inquebrantable con la calidad, combinando la tradición que nos define con la tecnología más avanzada para garantizar que cada gota que llega a ti sea un sinónimo de salud y frescura.\n\nA lo largo de las décadas, hemos crecido junto a las familias mexicanas, adaptándonos a sus necesidades pero sin perder nunca nuestra esencia. Creemos que el acceso a agua de calidad es fundamental para una vida plena, y es un honor para nosotros ser parte del día a día de miles de personas.",
                    style: AppStyles.bodyTextStyle.copyWith(fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppStyles.defaultPadding),
            
            // Tarjeta 2: Misión, Visión, Valores (apilados)
            Container(
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              decoration: AppStyles.cardDecoration,
              child: Column(
                children: const [
                  _InfoColumn(icon: Icons.track_changes, title: "Misión", text: "Proporcionar hidratación pura y accesible, mejorando la calidad de vida de nuestros clientes a través de productos y servicios de excelencia."),
                  Divider(height: 24),
                  _InfoColumn(icon: Icons.visibility, title: "Visión", text: "Ser la marca de agua purificada líder y de mayor confianza en México, reconocida por nuestra innovación, calidad y compromiso con la comunidad."),
                  Divider(height: 24),
                  _InfoColumn(icon: Icons.favorite_border, title: "Valores", text: "Calidad, Confianza, Integridad, Innovación y Responsabilidad Social."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de ayuda (igual que en web, pero centrado)
class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _InfoColumn({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppStyles.primaryColor, size: 32),
        const SizedBox(height: 12),
        Text(title, style: AppStyles.subheadingStyle),
        const SizedBox(height: 8),
        Text(text, style: AppStyles.bodyTextStyle.copyWith(color: AppStyles.lightTextColor), textAlign: TextAlign.center),
      ],
    );
  }
}