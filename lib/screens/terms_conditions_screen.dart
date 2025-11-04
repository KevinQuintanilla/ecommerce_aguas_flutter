import 'package:flutter/material.dart';
import '../widgets/static_page_layout.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageLayout(
      title: "Términos y Condiciones",
      lastUpdated: "19 de octubre de 2025",
      children: [
        LegalParagraph(
          text: "Bienvenido a Aguas de Lourdes. Estos términos y condiciones describen las reglas y regulaciones para el uso del sitio web de Aguas de Lourdes, ubicado en https://www.elsitio860.com/. Al acceder a este sitio web, asumimos que aceptas estos términos y condiciones. No continúes usando Aguas de Lourdes si no estás de acuerdo con todos los términos y condiciones establecidos en esta página.",
        ),
        LegalHeading(text: "1. Licencia"),
        LegalParagraph(
          text: "A menos que se indique lo contrario, Aguas de Lourdes y/o sus licenciantes poseen los derechos de propiedad intelectual de todo el material en Aguas de Lourdes. Todos los derechos de propiedad intelectual están reservados. Puedes acceder a esto desde Aguas de Lourdes para tu propio uso personal sujeto a las restricciones establecidas en estos términos y condiciones.",
        ),
        LegalHeading(text: "2. Uso del Sitio"),
        LegalParagraph(
          text: "Este sitio web es para fines informativos y de comercio electrónico (simulado). No debes:\n\nVolver a publicar material de Aguas de Lourdes.\nVender, alquilar o sublicenciar material de Aguas de Lourdes.\nReproducir, duplicar o copiar material de Aguas de Lourdes.",
        ),
        LegalHeading(text: "3. Descargo de responsabilidad"),
        LegalParagraph(
          text: "La información y los productos en este sitio se proporcionan \"tal cual\". Aguas de Lourdes no ofrece garantías, expresas o implícitas, y por la presente renuncia y niega todas las demás garantías. Este es un proyecto de demostración y no se procesarán transacciones reales.",
        ),
      ],
    );
  }
}