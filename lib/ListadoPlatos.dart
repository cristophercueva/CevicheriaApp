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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Listado de Platos',
          style: TextStyle(
            color: Color(0xFF111418),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF111418)),
      ),
      body: FutureBuilder<List<Plato>>(
        future: _platosFuturos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('❌ Error al cargar los platos'));
          }

          final platos = snapshot.data ?? [];

          if (platos.isEmpty) {
            return Center(child: Text('📭 No hay platos registrados.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: platos.length,
            itemBuilder: (context, i) {
              final p = platos[i];
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
                            p.plato,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF111418),
                            ),
                          ),
                          Text(
                            p.tipo,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF637488),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Precio: S/ ${p.precio.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF637488),
                            ),
                          ),
                          Text(
                            _formatearFecha(p.fecha),
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
                          onPressed: () => _editarPlato(p),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarEliminacion(context, p.id),
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
            MaterialPageRoute(builder: (_) => RegistrarPlato()),
          );
          if (result == true) {
            setState(() {});
          }
        },
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}
