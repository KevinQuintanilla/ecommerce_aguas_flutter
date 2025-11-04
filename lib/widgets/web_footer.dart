import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- 1. Importa Provider
import '../providers/navigation_provider.dart'; // <-- 2. Importa NavProvider
import '../utils/app_styles.dart';
import '../screens/about_us_screen.dart';
import '../screens/find_us_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/terms_conditions_screen.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el provider para el botón "Tienda"
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);

    return Container(
      color: AppStyles.primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna 1: Logo (sin cambios)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.local_drink, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Aguas de Lourdes',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pureza y tradición desde 1937.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),

              // --- 4. ACTUALIZA LA COLUMNA DE NAVEGACIÓN ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Navegación',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  _FooterLink(
                      text: 'Tienda',
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        navigationProvider.goToProducts();
                      }),
                  _FooterLink(
                    text: 'Nosotros',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AboutUsScreen()),
                      );
                    },
                  ),
                  _FooterLink(
                    text: 'Encuéntranos',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FindUsScreen()),
                      );
                    },
                  ),
                ],
              ),

              // --- 5. ACTUALIZA LA COLUMNA LEGAL ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Legal',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  _FooterLink(
                    text: 'Política de Privacidad',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyScreen()),
                      );
                    },
                  ),
                  _FooterLink(
                    text: 'Términos y Condiciones',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const TermsConditionsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          const Text(
            '© 2025 Aguas de Lourdes. Todos los derechos reservados.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Widget interno para los links del footer
class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _FooterLink({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onPressed,
        hoverColor: Colors.transparent, // Para que se sienta como link
        child: Text(
          text,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
