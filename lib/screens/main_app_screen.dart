import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/carrito_provider.dart';
import '../utils/app_styles.dart';
import 'home_screen.dart';
import 'mobile_productos_screen.dart';
import 'web_productos_screen.dart';
import 'mobile_carrito_screen.dart';
import 'mobile_perfil_screen.dart';
import 'web_home_screen.dart';
import 'web_carrito_screen.dart';
import 'web_perfil_screen.dart';
class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        
        // El mismo punto de quiebre
        if (constraints.maxWidth > 700) {
          return _buildCurrentScreen(context, isWeb: true);
          
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: _buildCurrentScreen(context, isWeb: false),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
  Widget _buildCurrentScreen(BuildContext context, {required bool isWeb}) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final currentIndex = navigationProvider.currentIndex;
    if (isWeb) {
      switch (currentIndex) {
        case 0:
          return const WebHomeScreen(); // <-- Pantalla especial web
        case 1:
          return const WebProductosScreen();
        case 2:
          return const WebCarritoScreen(); // TODO: Crear WebCarritoScreen
        case 3:
          return const WebPerfilScreen(); // TODO: Crear WebPerfilScreen
        default:
          return const WebHomeScreen();
      }
    } 
    else {
      switch (currentIndex) {
        case 0:
          return const HomeScreen(); 
        case 1:
          return const MobileProductosScreen();
        case 2:
          return const MobileCarritoScreen();
        case 3:
          return const MobilePerfilScreen();
        default:
          return const HomeScreen();
      }
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