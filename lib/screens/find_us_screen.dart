import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/web_header.dart';
import '../widgets/web_footer.dart';
import '../widgets/responsive_layout.dart';
import '../utils/app_styles.dart';
import '../widgets/web_page_layout.dart'; // Importa el layout principal

class FindUsScreen extends StatelessWidget {
  const FindUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WebPageLayout(
      selectedIndex: -1, // No es una pestaña principal
      backgroundColor: Colors.white,
      body: ResponsiveLayout(
        maxWidth: 1000,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60, horizontal: 24),
          child: _Content(), // El contenido interactivo
        ),
      ),
    );
  }
}

// Convertido a StatefulWidget para manejar el mapa
class _Content extends StatefulWidget {
  const _Content();
  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  // Cámara inicial (Plaza de Armas, SLP)
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(22.1523, -100.9782),
    zoom: 13.0,
  );

  // Marcadores (pines)
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('distribuidor_centro'),
      position: LatLng(22.1523, -100.9782), 
      infoWindow: InfoWindow(
        title: 'Distribuidor Centro',
        snippet: 'Av. Siempre Viva 123, Centro',
      ),
    ),
    const Marker(
      markerId: MarkerId('distribuidor_norte'),
      position: LatLng(22.1650, -100.9850), 
      infoWindow: InfoWindow(
        title: 'Distribuidor Norte',
        snippet: 'Calle Falsa 456, Col. Norte',
      ),
    ),
    const Marker(
      markerId: MarkerId('distribuidor_sur'),
      position: LatLng(22.1410, -100.9710), 
      infoWindow: InfoWindow(
        title: 'Distribuidor Sur',
        snippet: 'Blvd. de los Sueños Rotos 789, Sur',
      ),
    ),
  };

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
                children: [
                  Text("Distribuidores Autorizados", style: AppStyles.headingStyle.copyWith(fontSize: 24, color: AppStyles.primaryColor)),
                  const SizedBox(height: 24),
                  const _DistributorInfo(title: "Distribuidor Centro", address: "Av. Siempre Viva 123, Centro", icon: Icons.store_mall_directory),
                  const _DistributorInfo(title: "Distribuidor Norte", address: "Calle Falsa 456, Col. Norte", icon: Icons.store_mall_directory),
                  const _DistributorInfo(title: "Distribuidor Sur", address: "Blvd. de los Sueños Rotos 789, Sur", icon: Icons.store_mall_directory),
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppStyles.borderColor),
                ),
                child: ClipRRect( // Para que el mapa respete los bordes
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _kInitialPosition,
                    markers: _markers,
                    onMapCreated: (GoogleMapController controller) {
                      // (Puedes guardar el controlador si quieres)
                    },
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