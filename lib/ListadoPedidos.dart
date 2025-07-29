import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'pedido.dart';

class ListadoPedidos extends StatefulWidget {
  @override
  _ListadoPedidosState createState() => _ListadoPedidosState();
}

class _ListadoPedidosState extends State<ListadoPedidos> {
  late Future<List<Pedido>> _pedidosFuturos;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _pedidosFuturos = FirebaseHelper.obtenerPedidosPorFecha(hoy);
  }

  void _actualizarListado() {
    setState(() {
      final hoy = DateTime.now();
      _pedidosFuturos = FirebaseHelper.obtenerPedidosPorFecha(hoy);
    });
  }

  void _eliminarPedido(String id) async {
    await FirebaseHelper.eliminarPedido(id);
    _actualizarListado();
    Navigator.pop(context, true);
  }

  void _confirmarEliminacion(BuildContext context, String id) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('¿Eliminar pedido?'),
            content: Text('¿Estás seguro de que deseas eliminar este pedido?'),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _eliminarPedido(id);
                },
              ),
            ],
          ),
    );
  }

  void _mostrarDialogoEstado(Pedido pedido) {
    if (pedido.estado == 'Pagado') {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Información del Pedido'),
              content: Text(
                'Este pedido ya fue pagado.\nReferencia: ${pedido.referencia}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cerrar'),
                ),
              ],
            ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Cambiar estado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Deseas marcar este pedido como PAGADO?'),
                SizedBox(height: 12),
                Text(
                  'Referencia: ${pedido.referencia}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseHelper.actualizarEstadoPedido(
                    pedido.id,
                    'Pagado',
                  );
                  Navigator.pop(context);
                  _actualizarListado();
                },
                child: Text('Sí, Marcar como Pagado'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Listado de Pedidos')),
      body: FutureBuilder<List<Pedido>>(
        future: _pedidosFuturos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('❌ Error al cargar los pedidos'));
          }

          final pedidos = snapshot.data;

          if (pedidos == null || pedidos.isEmpty) {
            return Center(child: Text('📭 No hay pedidos registrados.'));
          }

          return ListView.separated(
            itemCount: pedidos.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, i) {
              final p = pedidos[i];
              final estadoColor =
                  p.estado == 'Pagado' ? Colors.green : Colors.amber;

              return ListTile(
                onTap: () => _mostrarDialogoEstado(p),
                title: Text('${p.plato} x ${p.cantidad}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ' Precio : ${p.preciofinal} soles -  Fecha:${p.fecha.toLocal()}',
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: estadoColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.estado,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _confirmarEliminacion(context, p.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
