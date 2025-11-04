import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/static_page_layout.dart' show LegalHeading, LegalParagraph;

class PrivacyPolicyLoginScreen extends StatelessWidget {
  const PrivacyPolicyLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppStyles.backgroundColor, // Fondo gris
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppStyles.primaryColor,
          elevation: 1,
          title: const Text("Política de Privacidad"),
        ),
        body: ResponsiveLayout(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppStyles.largePadding),
                decoration: AppStyles.cardDecoration, // Tarjeta blanca
                constraints:
                    const BoxConstraints(maxWidth: 900), // Ancho de texto
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Política de Privacidad",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppStyles.primaryColor),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Última actualización: 19 de octubre de 2025",
                      style: TextStyle(
                          fontSize: 14,
                          color: AppStyles.lightTextColor,
                          fontStyle: FontStyle.italic),
                    ),
                    Divider(height: 40),
                    LegalParagraph(
                      text:
                          "Esta Política de privacidad describe cómo se recopila, utiliza y comparte su información personal cuando visita o hace una compra en https://www.aguasdelourdes.com.mx/ (denominado en lo sucesivo el “Sitio”).",
                    ),
                    LegalHeading(text: "INFORMACIÓN PERSONAL QUE RECOPILAMOS"),
                    LegalParagraph(
                      text:
                          "Cuando visita el Sitio, recopilamos automáticamente cierta información sobre su dispositivo, incluida información sobre su navegador web, dirección IP, zona horaria y algunas of the cookies que están instaladas en su dispositivo...",
                    ),
                    LegalParagraph(
                      text:
                          "Recopilamos Información del dispositivo mediante el uso de las siguientes tecnologías...",
                    ),
                    _BulletList(
                      items: [
                        "COOKIES: Aquí tienes una lista de cookies que utilizamos. o _session_id: unique token, sessional... (etc)",
                        "Los “Archivos de registro” rastrean las acciones que ocurren en el Sitio y recopilan datos, incluyendo su dirección IP, tipo de navegador, proveedor de servicio de Internet, páginas de referencia/salida y marcas de fecha/horario.",
                        "Las “balizas web”, las “etiquetas” y los “píxeles” son archivos electrónicos utilizados para registrar información sobre cómo navega usted por el Sitio.",
                      ],
                    ),
                    LegalParagraph(
                      text:
                          "Además, cuando hace una compra o intenta hacer una compra a través del Sitio, recopilamos cierta información de usted, entre la que se incluye su nombre, dirección de facturación, dirección de envío, información de pago (incluidos los números de la tarjeta de créditoo), dirección de correo electrónico y número de teléfono. Nos referimos a esta información como “Información del pedido”.",
                    ),
                    LegalParagraph(
                      text:
                          "Cuando hablamos de “Información personal” en la presente Política de privacidad, nos referimos tanto a la Información del dispositivo como a la Información del pedido.",
                    ),
                    LegalHeading(
                        text: "¿CÓMO UTILIZAMOS SU INFORMACIÓN PERSONAL?"),
                    LegalParagraph(
                      text:
                          "Usamos la Información del pedido que recopilamos en general para preparar los pedidos realizados a través del Sitio (incluido el procesamiento de su información de pago, la organización de los envíos y la entrega de facturas y/o confirmaciones de pedido). Además, utilizamos esta Información del pedido para:\n\n• Comunicarnos con usted;\n• Examinar nuestros pedidos en busca de fraudes o riesgos potenciales;\n• Cuando de acuerdo con las preferencias que usted compartió con nosotros, le proporcionamos información o publicidad relacionada con nuestros productos o servicios.",
                    ),
                    LegalParagraph(
                      text:
                          "Utilizamos la Información del dispositivo que recopilamos para ayudarnos a detectar posibles riesgos y fraudes (en particular, su dirección IP) y, en general, para mejorar y optimizar nuestro Sitio (por ejemplo, al generar informes y estadísticas sobre cómo nuestros clientes navegan e interactúan con el Sitio y para evaluar el éxito de nuestras campañas publicitarias y de marketing). Además de que podemos utilizar esta información para publicidad digital con fines de retargeting.",
                    ),
                    LegalHeading(text: "COMPARTIR SU INFORMACIÓN PERSONAL"),
                    LegalParagraph(
                      text:
                          "Compartimos su Información personal con terceros para que nos ayuden a utilizar su Información personal, tal como se describió anteriormente. Por ejemplo, utilizamos la tecnología de Shopify en nuestra tienda online. Puede obtener más información sobre cómo Shopify utiliza su Información personal aquí: https://www.shopify.com/legal/privacy.\n\nTambién utilizamos Google Analytics para ayudarnos a comprender cómo usan nuestros clientes el Sitio. Puede obtener más información sobre cómo Google utiliza su Información personal aquí: https://www.google.com/intl/es/policies/privacy/.",
                    ),
                    LegalHeading(
                        text: "PUBLICIDAD ORIENTADA POR EL COMPORTAMIENTO"),
                    LegalParagraph(
                      text:
                          "Como se describió anteriormente, utilizamos su Información personal para proporcionarle anuncios publicitarios dirigidos o comunicaciones de marketing que creemos que pueden ser de su interés. Para más información sobre cómo funciona la publicidad dirigida, puede visitar la página educativa de la Iniciativa Publicitaria en la Red (\"NAI\" por sus siglas en inglés) en http://www.networkadvertising.org/understanding-online-advertising/how-does-it- work.",
                    ),
                    LegalHeading(text: "NO RASTREAR"),
                    LegalParagraph(
                      text:
                          "Tenga en cuenta que no alteramos las prácticas de recopilación y uso de datos de nuestro Sitio cuando vemos una señal de No rastrear desde su navegador.",
                    ),
                    LegalHeading(text: "SUS DERECHOS"),
                    LegalParagraph(
                      text:
                          "Si usted es un residente europeo, tiene derecho a acceder a la información personal que tenemos sobre usted y a solicitar que su información personal sea corregida, actualizada o eliminada. Si desea ejercer este derecho, comuníquese con nosotros a través de la información de contacto que se encuentra a continuación.",
                    ),
                    LegalHeading(text: "RETENCIÓN DE DATOS"),
                    LegalParagraph(
                      text:
                          "Cuando realiza un pedido a través del Sitio, mantendremos su Información del pedido para nuestros registros a menos que y hasta que nos pida que eliminemos esta información.",
                    ),
                    LegalHeading(text: "MENORES"),
                    LegalParagraph(
                      text:
                          "El sitio no está destinado a personas menores de 18 años.",
                    ),
                    LegalHeading(text: "CAMBIOS"),
                    LegalParagraph(
                      text:
                          "Podemos actualizar esta política de privacidad periódicamente para reflejar, por ejemplo, cambios en nuestras prácticas o por otros motivos operativos, legales o reglamentarios.",
                    ),
                    LegalHeading(text: "CONTÁCTENOS"),
                    LegalParagraph(
                      text:
                          "Para obtener más información sobre nuestras prácticas de privacidad, si tiene alguna pregunta o si desea presentar una queja, contáctenos por correo electrónico a marketing@aguasdelourdes.com.mx o por correo mediante el uso de la información que se proporciona a continuación:\n\nFrancisco Zarco 389, San Luis Potosí, San Luis Potosí, 78280, México.",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

// Widget de ayuda para las listas
class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ",
                          style: TextStyle(fontSize: 16, height: 1.6)),
                      Expanded(
                        child: Text(item,
                            style: const TextStyle(fontSize: 16, height: 1.6)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
