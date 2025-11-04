import 'package:flutter/material.dart';
import '../widgets/static_page_layout.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageLayout(
      title: "Política de Privacidad",
      lastUpdated: "19 de octubre de 2025",
      children: [
        LegalParagraph(
          text: "En Aguas de Lourdes, S.A. de C.V., respetamos tu privacidad y estamos comprometidos a proteger tus datos personales. Este aviso de privacidad te informará sobre cómo cuidamos tus datos personales cuando visitas nuestro sitio web (independientemente de dónde lo visites) y te informará sobre tus derechos de privacidad y cómo la ley te protege.",
        ),
        LegalHeading(text: "1. Información que recopilamos"),
        LegalParagraph(
          text: "Podemos recopilar, usar, almacenar y transferir diferentes tipos de datos personales sobre ti, que hemos agrupado de la siguiente manera:",
        ),
        LegalParagraph(
          text: "Datos de Identidad: incluye nombre, apellido, nombre de usuario o identificador similar.\nDatos de Contacto: incluye dirección de facturación, dirección de entrega, dirección de correo electrónico y números de teléfono.\nDatos de Transacción: incluye detalles sobre los pagos desde y hacia ti y otros detalles de productos y servicios que nos has comprado. (Este es un sitio de demostración, no se recopilan datos reales de pago).",
        ),
        LegalHeading(text: "2. Cómo usamos tus datos personales"),
        LegalParagraph(
          text: "Usaremos tus datos personales solo cuando la ley nos lo permita. Generalmente, usaremos tus datos personales en las siguientes circunstancias:\n\nPara procesar y entregar tu pedido.\nPara gestionar nuestra relación contigo, lo que incluirá notificarte sobre cambios en nuestros términos o política de privacidad.",
        ),
        LegalHeading(text: "3. Tus derechos legales"),
        LegalParagraph(
          text: "Bajo ciertas circunstancias, tienes derechos bajo las leyes de protección de datos en relación con tus datos personales, incluyendo el derecho a solicitar acceso, corrección, eliminación, restricción, transferencia, de tus datos personales.",
        ),
      ],
    );
  }
}