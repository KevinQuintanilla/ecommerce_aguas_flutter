import 'package:flutter/material.dart';
import '../widgets/web_header.dart';
import '../widgets/web_footer.dart';
import '../widgets/responsive_layout.dart';
import '../utils/app_styles.dart';

class FindUsScreen extends StatelessWidget {
  const FindUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 0:Inicio, 1:Tienda, 2:Nosotros, 3:Encuentranos
            WebHeader(selectedIndex: 3), 
            ResponsiveLayout(
              maxWidth: 1000,
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
        Text("Encuéntranos", style: AppStyles.headingStyle.copyWith(fontSize: 36, color: AppStyles.primaryColor)),
        const SizedBox(height: 16),
        Text("Siempre hay un punto de Aguas de Lourdes cerca de ti.", style: AppStyles.bodyTextStyle.copyWith(fontSize: 18, color: AppStyles.lightTextColor)),
        const SizedBox(height: 40),
        // Layout de 2 columnas
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna Izquierda: Distribuidores
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text("Distribuidores Autorizados", style: AppStyles.headingStyle.copyWith(fontSize: 24, color: AppStyles.primaryColor)),
                  SizedBox(height: 24),
                  _DistributorInfo(title: "Distribuidor Centro", address: "Av. Siempre Viva 123, Centro", icon: Icons.store_mall_directory),
                  _DistributorInfo(title: "Distribuidor Norte", address: "Calle Falsa 456, Col. Norte", icon: Icons.store_mall_directory),
                  _DistributorInfo(title: "Distribuidor Sur", address: "Blvd. de los Sueños Rotos 789, Sur", icon: Icons.store_mall_directory),
                ],
              ),
            ),
            const SizedBox(width: 40),
            // Columna Derecha: Mapa
            Expanded(
              flex: 2,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  color: AppStyles.borderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_pin, size: 40, color: AppStyles.lightTextColor),
                      const SizedBox(height: 8),
                      Text("Placeholder para mapa interactivo", style: AppStyles.bodyTextStyle.copyWith(color: AppStyles.lightTextColor)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Widget de ayuda para la info del distribuidor
class _DistributorInfo extends StatelessWidget {
  final String title;
  final String address;
  final IconData icon;
  const _DistributorInfo({required this.title, required this.address, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppStyles.primaryColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.subheadingStyle.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text(address, style: AppStyles.bodyTextStyle.copyWith(color: AppStyles.lightTextColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}