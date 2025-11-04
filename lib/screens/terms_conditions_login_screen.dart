import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/static_page_layout.dart' show LegalHeading, LegalParagraph;

class TermsConditionsLoginScreen extends StatelessWidget {
  const TermsConditionsLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor, // Fondo gris
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
        title: const Text("Términos y Condiciones"),
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
                    "Términos y Condiciones",
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
                        "Bienvenido al sitio web de Balneario y Manantiales de Lourdes. Al acceder y utilizar nuestro sitio web, acepta los siguientes Términos y Condiciones. Le recomendamos que los lea detenidamente antes de realizar cualquier compra o interactuar con nuestra plataforma.",
                  ),
                  LegalHeading(text: "1. Aceptación de los Términos"),
                  LegalParagraph(
                    text:
                        "Al acceder, navegar y utilizar este sitio web, usted acepta cumplir con los presentes Términos y Condiciones. Si no está de acuerdo con alguno de estos términos, le rogamos no utilizar nuestro sitio.",
                  ),
                  LegalHeading(text: "2. Propiedad Intelectual"),
                  LegalParagraph(
                    text:
                        "Todo el contenido disponible en este sitio web, incluidos textos, gráficos, logotipos, imágenes, videos, y software, es propiedad de Balneario y Manantiales de Lourdes o de sus proveedores de contenido y está protegido por las leyes de propiedad intelectual. Queda prohibido el uso no autorizado de cualquier contenido sin el permiso expreso por escrito de nuestra empresa.",
                  ),
                  LegalHeading(text: "3. Uso del Sitio"),
                  LegalParagraph(
                    text:
                        "Este sitio web está destinado únicamente para el uso personal y no comercial de los usuarios. No está permitido reproducir, duplicar, copiar, vender o explotar ninguna parte de este sitio web sin el consentimiento expreso de Balneario y Manantiales de Lourdes.",
                  ),
                  LegalHeading(text: "4. Registro de Cuenta"),
                  LegalParagraph(
                    text:
                        "Para realizar compras en nuestro sitio web, puede ser necesario crear una cuenta de usuario. Usted es responsable de mantener la confidencialidad de la información de su cuenta, incluyendo su contraseña, y de todas las actividades que se realicen desde su cuenta. Nos reservamos el derecho de cancelar cuentas, rechazar pedidos y remover o editar contenido a nuestra discreción.",
                  ),
                  LegalHeading(text: "5. Precios y Disponibilidad"),
                  LegalParagraph(
                    text:
                        "Todos los precios de nuestros productos están expresados en [moneda local] y pueden estar sujetos a cambios sin previo aviso. Nos reservamos el derecho de modificar los precios o descontinuar productos en cualquier momento. La disponibilidad de los productos está sujeta al inventario y no garantizamos la existencia permanente de ningún artículo.",
                  ),
                  LegalHeading(text: "6. Política de Pagos"),
                  LegalParagraph(
                    text:
                        "Aceptamos diversas formas de pago, como tarjetas de crédito y débito, transferencias bancarias y otros métodos indicados en nuestro sitio web. Todos los pagos deben realizarse al momento de la compra. Nos reservamos el derecho de rechazar cualquier transacción que consideremos sospechosa o fraudulenta.",
                  ),
                  LegalHeading(text: "7. Envíos y Entregas"),
                  LegalParagraph(
                    text:
                        "Realizamos envíos dentro de México. Los tiempos de entrega estimados varían según la ubicación y serán proporcionados al momento de realizar el pedido. Balneario y Manantiales de Lourdes no se hace responsable por retrasos en la entrega ocasionados por eventos fuera de nuestro control, como desastres naturales o problemas logísticos de las empresas de mensajería.",
                  ),
                  LegalHeading(text: "8. Devoluciones y Reembolsos"),
                  LegalParagraph(
                    text:
                        "Nuestra política de devoluciones permite a los clientes devolver productos dentro de un plazo de [número de días] desde la fecha de recepción, siempre y cuando el producto esté en su estado original. Para más detalles sobre los procedimientos y condiciones de devolución, consulte nuestra Política de Devoluciones disponible en el sitio.",
                  ),
                  LegalHeading(text: "9. Garantías"),
                  LegalParagraph(
                    text:
                        "Los productos ofrecidos en nuestro sitio cuentan con las garantías establecidas por los fabricantes. Si un producto presenta defectos de fabricación, usted tiene derecho a solicitar la reparación o reemplazo del mismo dentro del período de garantía aplicable.",
                  ),
                  LegalHeading(text: "10. Limitación de Responsabilidad"),
                  LegalParagraph(
                    text:
                        "Balneario y Manantiales de Lourdes no será responsable por ningún daño directo, indirecto, incidental o consecuente que resulte del uso o la incapacidad de uso de nuestro sitio web o productos adquiridos, incluidos pero no limitados a pérdida de ingresos, datos o reputación.",
                  ),
                  LegalHeading(
                      text: "11. Modificaciones a los Términos y Condiciones"),
                  LegalParagraph(
                    text:
                        "Nos reservamos el derecho de modificar o actualizar estos Términos y Condiciones en cualquier momento sin previo aviso. Los cambios serán efectivos una vez publicados en esta página. Es su responsabilidad revisar estos términos periódicamente.",
                  ),
                  LegalHeading(text: "12. Legislación Aplicable"),
                  LegalParagraph(
                    text:
                        "Estos Términos y Condiciones se rigen por las leyes de México, y cualquier disputa que surja en relación con el uso de este sitio web o los productos adquiridos será resuelta por los tribunales competentes de [jurisdicción].",
                  ),
                  LegalHeading(text: "13. Contacto"),
                  LegalParagraph(
                    text:
                        "Si tiene alguna duda o comentario sobre estos Términos y Condiciones, puede ponerse en contacto con nosotros a través de:\n\nCorreo electrónico: marketing@aguasdelourdes.com.mx",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
