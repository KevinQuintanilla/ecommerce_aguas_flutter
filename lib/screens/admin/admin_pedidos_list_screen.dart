import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_styles.dart';
import 'admin_detalle_pedido_screen.dart';
import '../../models/pedido.dart';

class AdminPedidosListScreen extends StatefulWidget {
  const AdminPedidosListScreen({super.key});

  @override
  State<AdminPedidosListScreen> createState() => _AdminPedidosListScreenState();
}

class _AdminPedidosListScreenState extends State<AdminPedidosListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).cargarTodosLosPedidos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Pedidos'),
        backgroundColor: AppStyles.cardColor,
        foregroundColor: AppStyles.primaryColor,
        elevation: 1, // Añadimos elevación
      ),
      backgroundColor: AppStyles.backgroundColor, // Fondo gris
      body: RefreshIndicator(
        onRefresh: () => adminProvider.cargarTodosLosPedidos(),
        child: _buildBody(adminProvider),
      ),
    );
  }

  Widget _buildBody(AdminProvider provider) {
    if (provider.cargando && provider.todosLosPedidos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error.isNotEmpty) {
      return Center(child: Text('Error: ${provider.error}'));
    }

    if (provider.todosLosPedidos.isEmpty) {
      // --- CENTRADO EN EL CASO VACÍO ---
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined, size: 80, color: AppStyles.lightTextColor),
            SizedBox(height: 16),
            Text('No se encontraron pedidos.', style: AppStyles.bodyTextStyle),
          ],
        ),
      );
      // --- FIN DE CENTRADO ---
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      itemCount: provider.todosLosPedidos.length,
      itemBuilder: (context, index) {
        final pedido = provider.todosLosPedidos[index];
        return _buildPedidoCard(pedido);
      },
    );
  }

  Widget _buildPedidoCard(Pedido pedido) {
    return Card(
      elevation: 2, // Aumentamos la elevación
      margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
        side: const BorderSide(color: AppStyles.borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppStyles.defaultPadding),
        title: Text(
          'Pedido #${pedido.pedidoId}',
          style: AppStyles.subheadingStyle.copyWith(fontSize: 16, color: AppStyles.textColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrando los datos del cliente
            Text(
              'Cliente: ${pedido.clienteNombre} ${pedido.clienteApellido}',
              style: AppStyles.bodyTextStyle.copyWith(fontSize: 14),
            ),
            Text(
              'Fecha: ${pedido.fechaPedido.toLocal().toString().split(' ')[0]}',
              style: AppStyles.captionStyle,
            ),
            // Total con color primario
            Text(
              'Total: \$${pedido.total.toStringAsFixed(2)}',
              style: AppStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.bold, color: AppStyles.primaryColor),
            ),
          ],
        ),
        trailing: _buildBadgeEstado(pedido.estadoDisplay, pedido.estadoPedidoId),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDetallePedidoScreen(pedido: pedido),
            ),
          );
        },
      ),
    );
  }

  // (Widget de ayuda para el badge de estado, queda igual)
  Widget _buildBadgeEstado(String estado, int estadoId) {
    Color color;
    switch (estadoId) {
      case 1: color = AppStyles.infoColor; break;
      case 2: color = AppStyles.warningColor; break;
      case 3: color = AppStyles.primaryColor; break;
      case 4: color = AppStyles.successColor; break;
      case 5: color = AppStyles.errorColor; break;
      default: color = AppStyles.lightTextColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(estado, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}