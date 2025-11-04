import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../utils/app_styles.dart';
import '../screens/about_us_screen.dart';
import '../screens/find_us_screen.dart';

class WebHeader extends StatelessWidget {
  final int selectedIndex;

  const WebHeader({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      color: AppStyles.primaryColor,
      child: Row(
        children: [
          // Logo
          InkWell(
            onTap: (){
              Navigator.of(context).popUntil((route) => route.isFirst);
              navigationProvider.goToHome();
            },
            child: Row(
              children: const [
                Icon(Icons.local_drink, color: Colors.white),
                SizedBox(width: 12),
                Text('Aguas de Lourdes',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          const Spacer(), // Ocupa el espacio del medio
          
          // --- BOTONES DE PESTAÑA PRINCIPAL ---
          _WebNavButton(
              title: 'Inicio',
              isSelected: selectedIndex == 0,
              onPressed: (){
                Navigator.of(context).popUntil((route) => route.isFirst);
                navigationProvider.goToHome();
              }),
          _WebNavButton(
              title: 'Tienda',
              isSelected: selectedIndex == 1,
              onPressed: (){
                Navigator.of(context).popUntil((route) => route.isFirst);
                navigationProvider.goToProducts();
              }),
          _WebNavButton(
              title: 'Nosotros',
              isSelected: false, 
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsScreen()),
                );
              }),
          _WebNavButton(
              title: 'Encuéntranos',
              isSelected: false,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FindUsScreen()),
                );
              }),
          
          // --- ICONOS DE PESTAÑA PRINCIPAL ---
          IconButton(
            icon: Icon(
              selectedIndex == 2 ? Icons.shopping_cart : Icons.shopping_cart_outlined,
              color: selectedIndex == 2 ? AppStyles.accentColor : Colors.white,
            ),
            onPressed: (){
              Navigator.of(context).popUntil((route) => route.isFirst);
              navigationProvider.goToCart();
            },
          ),
          IconButton(
            icon: Icon(
              selectedIndex == 3 ? Icons.person : Icons.person_outline,
              color: selectedIndex == 3 ? AppStyles.accentColor : Colors.white,
            ),
            onPressed: () =>{
              Navigator.of(context).popUntil((route) => route.isFirst),
              navigationProvider.goToProfile()
            },
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

// (El widget _WebNavButton queda igual que en mi mensaje anterior)
class _WebNavButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onPressed;
  const _WebNavButton({ required this.title, required this.isSelected, required this.onPressed, });
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppStyles.accentColor : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }
}