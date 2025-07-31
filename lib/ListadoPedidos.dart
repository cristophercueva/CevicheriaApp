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

  Future<bool?> _confirmarEliminacion(BuildContext context, String id) async {
    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 6,
                margin: EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Text(
                '¿Eliminar pedido?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111418),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '¿Estás seguro de que deseas eliminar este pedido?\nEsta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF637488)),
              ),
              SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Color(0xFFE5E7EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Color(0xFFDC2626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Eliminar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (resultado == true) {
      _eliminarPedido(id);
      return true;
    }
    return false;
  }

  void _mostrarDialogoEstado(Pedido pedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final bool yaPagado = pedido.estado == 'Pagado';

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Línea gris superior
                Container(
                  width: 48,
                  height: 6,
                  margin: EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Text(
                  yaPagado ? 'Pedido ya pagado' : '¿Marcar pedido como pagado?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Referencia: ${pedido.referencia}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                ),
                SizedBox(height: 32),

                if (!yaPagado) ...[
                  // Botón marcar como pagado
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseHelper.actualizarEstadoPedido(
                          pedido.id,
                          'Pagado',
                        );
                        Navigator.pop(context);
                        _actualizarListado();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3F7FBF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'Sí, marcar como pagado',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                ],

                // Botón cerrar
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      yaPagado ? 'Cerrar' : 'Cancelar',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9), // fondo similar a --background-color
      appBar: AppBar(
        title: Text(
          'Listado de Pedidos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111418),
        elevation: 1,
      ),
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

          return ListView.builder(
            itemCount: pedidos.length,
            padding: EdgeInsets.all(12),
            itemBuilder: (context, i) {
              final p = pedidos[i];
              final estadoColor =
                  p.estado == 'Pagado'
                      ? Color(0xFF22C55E)
                      : Color(0xFFF59E0B); // éxito o advertencia
              final estadoTexto = p.estado == 'Pagado' ? 'Paid' : 'Pending';

              return Dismissible(
                key: Key(p.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.delete, color: Colors.white, size: 28),
                ),
                confirmDismiss: (_) => _confirmarEliminacion(context, p.id),
                child: GestureDetector(
                  onTap: () => _mostrarDialogoEstado(p),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Detalles
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${p.plato} x ${p.cantidad}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'S/ ${p.preciofinal}  •  ${_formatearFecha(p.fecha)} ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF637488),
                                ),
                              ),
                              Text(
                                'Referencia :  ${p.referencia}  ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF637488),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Estado
                        // Estado y botón eliminar
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: estadoColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                estadoTexto,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 20),
                              color: Colors.redAccent,
                              style: IconButton.styleFrom(
                                backgroundColor: Color(0xFFFDEAEA),
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(10),
                              ),
                              onPressed: () async {
                                final confirmado = await _confirmarEliminacion(
                                  context,
                                  p.id,
                                );
                                if (confirmado == true) {
                                  setState(
                                    () {},
                                  ); // si lo necesitas para actualizar vista
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${meses[fecha.month - 1]} ${fecha.day}, ${fecha.year}';
  }
}
