import 'package:flutter/material.dart';
import '../widgets/web_header.dart';
import '../widgets/web_footer.dart';
import '../widgets/responsive_layout.dart';
import '../utils/app_styles.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 0:Inicio, 1:Tienda, 2:Nosotros, 3:Encuentranos
            WebHeader(selectedIndex: 2), 
            ResponsiveLayout(
              maxWidth: 900,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                child: _Content(),
              ),
            ),
            WebFooter(),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título
        Text("Nuestra Historia de Pureza", style: AppStyles.headingStyle.copyWith(fontSize: 36, color: AppStyles.primaryColor)),
        const SizedBox(height: 16),
        Text("Más de 80 años llevando bienestar a los hogares de México.", style: AppStyles.bodyTextStyle.copyWith(fontSize: 18, color: AppStyles.lightTextColor)),
        const SizedBox(height: 40),
        // Párrafos
        Text(
          "Fundada en 1937, Aguas de Lourdes nació con un simple pero poderoso objetivo: ofrecer el agua más pura y confiable a nuestra comunidad. Desde nuestra primera planta embotelladora, hemos mantenido un compromiso inquebrantable con la calidad, combinando la tradición que nos define con la tecnología más avanzada para garantizar que cada gota que llega a ti sea un sinónimo de salud y frescura.\n\nA lo largo de las décadas, hemos crecido junto a las familias mexicanas, adaptándonos a sus necesidades pero sin perder nunca nuestra esencia. Creemos que el acceso a agua de calidad es fundamental para una vida plena, y es un honor para nosotros ser parte del día a día de miles de personas.",
          style: AppStyles.bodyTextStyle.copyWith(fontSize: 16, height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 60),
        // Sección de 3 columnas
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _InfoColumn(icon: Icons.track_changes, title: "Misión", text: "Proporcionar hidratación pura y accesible, mejorando la calidad de vida de nuestros clientes a través de productos y servicios de excelencia.")),
            SizedBox(width: 24),
            Expanded(child: _InfoColumn(icon: Icons.visibility, title: "Visión", text: "Ser la marca de agua purificada líder y de mayor confianza en México, reconocida por nuestra innovación, calidad y compromiso con la comunidad.")),
            SizedBox(width: 24),
            Expanded(child: _InfoColumn(icon: Icons.favorite_border, title: "Valores", text: "Calidad, Confianza, Integridad, Innovación y Responsabilidad Social.")),
          ],
        )
      ],
    );
  }
}

// Widget de ayuda para la columna Misión/Visión/Valores
class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _InfoColumn({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppStyles.primaryColor, size: 40),
        const SizedBox(height: 16),
        Text(title, style: AppStyles.subheadingStyle.copyWith(color: AppStyles.primaryColor)),
        const SizedBox(height: 8),
        Text(text, style: AppStyles.bodyTextStyle.copyWith(color: AppStyles.lightTextColor), textAlign: TextAlign.center),
      ],
    );
  }
}