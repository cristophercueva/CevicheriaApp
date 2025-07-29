import 'package:flutter/material.dart';
import 'package:pedidos_app/registrar_plato.dart';
import 'db_helper.dart';
import 'plato.dart';

class ListadoPlatos extends StatefulWidget {
  @override
  _ListadoPlatosState createState() => _ListadoPlatosState();
}

class _ListadoPlatosState extends State<ListadoPlatos> {
  late Future<List<Plato>> _platosFuturos;

  @override
  void initState() {
    super.initState();
    _platosFuturos = FirebaseHelper.obtenerTodosPlatos();
  }

  void _eliminarPlato(String id) async {
    await FirebaseHelper.eliminarPlato(id);
    setState(() {
      _platosFuturos = FirebaseHelper.obtenerTodosPlatos();
    });
    Navigator.pop(context, true);
  }

  void _editarPlato(Plato plato) async {
    final actualizado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegistrarPlato(PlatoExistente: plato)),
    );

    if (actualizado == true) {
      setState(() {
        _platosFuturos = FirebaseHelper.obtenerTodosPlatos();
      });
    }
    Navigator.pop(context, true);
  }

  void _confirmarEliminacion(BuildContext context, String id) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('¿Eliminar Plato?'),
            content: Text('¿Estás seguro de que deseas eliminar este Plato?'),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Cierra el diálogo
                  _eliminarPlato(id); // Elimina el gasto
                  Navigator.pop(context, true);
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Listado de Platos')),
      body: FutureBuilder<List<Plato>>(
        future: _platosFuturos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('❌ Error al cargar los platos'));
          }

          final plato = snapshot.data;

          if (plato == null || plato.isEmpty) {
            return Center(child: Text('📭 No hay platos registrados.'));
          }

          return ListView.separated(
            itemCount: plato.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, i) {
              final p = plato[i];
              return ListTile(
                title: Text('${p.plato} - S/ ${p.precio}'),
                subtitle: Text('${p.tipo} - ${p.fecha.toLocal()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editarPlato(p),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _confirmarEliminacion(context, p.id),
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
