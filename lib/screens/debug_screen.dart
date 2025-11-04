import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/pedido_provider.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final pedidoProvider = Provider.of<PedidoProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Info')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usuario Autenticado: ${authProvider.estaAutenticado}', 
                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Cliente ID: ${authProvider.usuario?.clienteId}'),
            Text('Usuario: ${authProvider.usuario?.toJson()}'),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () {
                if (authProvider.usuario?.clienteId != null) {
                  pedidoProvider.cargarPedidos(authProvider.usuario!.clienteId!);
                }
              },
              child: const Text('Forzar Carga de Pedidos'),
            ),
            
            const SizedBox(height: 20),
            Text('Pedidos Cargados: ${pedidoProvider.pedidos.length}',
                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            
            ...pedidoProvider.pedidos.map((pedido) => Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pedido #${pedido.pedidoId}'),
                    Text('Estado: ${pedido.estadoDisplay}'),
                    Text('Total: \$${pedido.total}'),
                    Text('Artículos: ${pedido.articulos.length}'),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}