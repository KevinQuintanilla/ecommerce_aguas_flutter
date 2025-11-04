import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/carrito_provider.dart';
import '../utils/app_styles.dart';
import 'home_screen.dart';
import 'productos_screen.dart';
import 'carrito_screen.dart';
import 'perfil_screen.dart';

class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: _buildCurrentScreen(navigationProvider.currentIndex),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildCurrentScreen(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const ProductosScreen();
      case 2:
        return const CarritoScreen();
      case 3:
        return const PerfilScreen();
      default:
        return const HomeScreen();
    }
  }

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final carritoProvider = Provider.of<CarritoProvider>(context);

    return BottomNavigationBar(
      currentIndex: navigationProvider.currentIndex,
      onTap: (index) {
        navigationProvider.changeTab(index);
      },
      selectedItemColor: AppStyles.primaryColor,
      unselectedItemColor: AppStyles.lightTextColor,
      backgroundColor: AppStyles.cardColor,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Catálogo',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text(carritoProvider.totalItems.toString()),
            isLabelVisible: carritoProvider.totalItems > 0,
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          activeIcon: Badge(
            label: Text(carritoProvider.totalItems.toString()),
            isLabelVisible: carritoProvider.totalItems > 0,
            child: const Icon(Icons.shopping_cart),
          ),
          label: 'Carrito',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}