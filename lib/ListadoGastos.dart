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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Listado de Gastos')),
      body: FutureBuilder<List<Gastos>>(
        future: _gastosFuturos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('❌ Error al cargar los gastos'));
          }

          final plato = snapshot.data;

          if (plato == null || plato.isEmpty) {
            return Center(child: Text('📭 No hay gastos registrados.'));
          }

          final gastos = snapshot.data!;
          return ListView.separated(
            itemCount: gastos.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, i) {
              final g = gastos[i];
              return ListTile(
                title: Text('${g.nombre} - S/ ${g.precio} x ${g.cantidad}'),
                subtitle: Text('${g.tipo} - ${g.fecha.toLocal()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editarGasto(g),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _confirmarEliminacion(context, g.id!),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
