import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'gastos.dart';
import 'registrar_gasto.dart'; // Asegúrate que acepta argumentos opcionales

class ListadoGastos extends StatefulWidget {
  @override
  _ListadoGastosState createState() => _ListadoGastosState();
}

class _ListadoGastosState extends State<ListadoGastos> {
  late Future<List<Gastos>> _gastosFuturos;

  @override
  void initState() {
    super.initState();
    _gastosFuturos = FirebaseHelper.obtenerGastosDeHoy();
  }

  void _eliminarGasto(String id) async {
    await FirebaseHelper.eliminarGasto(id);
    setState(() {
      _gastosFuturos = FirebaseHelper.obtenerGastosDeHoy();
    });
    Navigator.pop(context, true);
  }

  void _editarGasto(Gastos gasto) async {
    final actualizado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegistrarGasto(gastoExistente: gasto)),
    );

    if (actualizado == true) {
      setState(() {
        _gastosFuturos = FirebaseHelper.obtenerGastosDeHoy();
      });
    }
    Navigator.pop(context, true);
  }

  void _confirmarEliminacion(BuildContext context, String id) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('¿Eliminar gasto?'),
            content: Text('¿Estás seguro de que deseas eliminar este gasto?'),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Cierra el diálogo
                  _eliminarGasto(id); // Elimina el gasto
                },
              ),
            ],
          ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Listado de Gastos',
          style: TextStyle(
            color: Color(0xFF111418),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF111418)),
      ),
      body: FutureBuilder<List<Gastos>>(
        future: _gastosFuturos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('❌ Error al cargar los gastos'));
          }

          final gastos = snapshot.data ?? [];

          if (gastos.isEmpty) {
            return Center(child: Text('📭 No hay gastos registrados.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: gastos.length,
            itemBuilder: (context, i) {
              final g = gastos[i];
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF111418),
                            ),
                          ),
                          Text(
                            g.tipo,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF637488),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Total: S/ ${(g.precio).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF637488),
                            ),
                          ),
                          Text(
                            _formatearFecha(g.fecha),
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF99A0B0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Color(0xFF3F7FBF)),
                          onPressed: () => _editarGasto(g),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed:
                              () => _confirmarEliminacion(context, g.id!),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF3F7FBF),
        child: Icon(Icons.add, size: 32),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RegistrarGasto()),
          );
          if (result == true) {
            setState(
              () {},
            ); // Refresca el listado si se registró un nuevo gasto
          }
        },
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}
