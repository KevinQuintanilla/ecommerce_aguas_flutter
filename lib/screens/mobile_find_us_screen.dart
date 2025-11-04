import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/app_styles.dart';

class MobileFindUsScreen extends StatefulWidget {
  const MobileFindUsScreen({super.key});

  @override
  State<MobileFindUsScreen> createState() => _MobileFindUsScreenState();
}

class _MobileFindUsScreenState extends State<MobileFindUsScreen> {
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
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text('Encuéntranos'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          children: [
            // Tarjeta 1: Mapa
            Container(
              height: 300, // Altura para el mapa en móvil
              decoration: AppStyles.cardDecoration,
              child: ClipRRect( // Para que el mapa respete los bordes
                borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
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
            const SizedBox(height: AppStyles.defaultPadding),

            // Tarjeta 2: Distribuidores
            Container(
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              decoration: AppStyles.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text("Distribuidores Autorizados", style: AppStyles.headingStyle.copyWith(fontSize: 20)),
                  Divider(height: 24),
                  _DistributorInfo(title: "Distribuidor Centro", address: "Av. Siempre Viva 123, Centro", icon: Icons.store_mall_directory),
                  Divider(height: 24),
                  _DistributorInfo(title: "Distribuidor Norte", address: "Calle Falsa 456, Col. Norte", icon: Icons.store_mall_directory),
                  Divider(height: 24),
                  _DistributorInfo(title: "Distribuidor Sur", address: "Blvd. de los Sueños Rotos 789, Sur", icon: Icons.store_mall_directory),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de ayuda (igual que en web)
class _DistributorInfo extends StatelessWidget {
  final String title;
  final String address;
  final IconData icon;
  const _DistributorInfo({required this.title, required this.address, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}