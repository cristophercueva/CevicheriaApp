import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'plato.dart';
import 'pedido.dart';

class RegistrarIngreso extends StatefulWidget {
  @override
  _RegistrarIngresoState createState() => _RegistrarIngresoState();
}

class _RegistrarIngresoState extends State<RegistrarIngreso> {
  late Future<List<Plato>> _platosFuturos;
  Map<String, TextEditingController> _controladoresCantidad = {};

  @override
  void initState() {
    super.initState();
    _platosFuturos = FirebaseHelper.obtenerTodosPlatos();
  }

  void _agregarIngreso(Plato plato) async {
    final controller = _controladoresCantidad[plato.id];
    final cantidadStr = controller?.text.trim();
    final cantidad = int.tryParse(cantidadStr ?? '');

    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cantidad inválida para ${plato.plato}')),
      );
      return;
    }

    Future<Map<String, String>?> _mostrarDialogoEstadoYReferencia() async {
      String estadoSeleccionado = 'Pendiente';
      TextEditingController referenciaController = TextEditingController();

      final resultado = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Información del pedido'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Selecciona el estado del pedido:'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                estadoSeleccionado == 'Pendiente'
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              estadoSeleccionado = 'Pendiente';
                            });
                          },
                          child: Text('Pendiente'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                estadoSeleccionado == 'Pagado'
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              estadoSeleccionado = 'Pagado';
                            });
                          },
                          child: Text('Pagado'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: referenciaController,
                      decoration: InputDecoration(
                        labelText: 'Referencia (obligatoria)',
                        errorText:
                            referenciaController.text.trim().isEmpty
                                ? 'Este campo es requerido'
                                : null,
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (referenciaController.text.trim().isEmpty) return;
                      Navigator.of(context).pop({
                        'estado': estadoSeleccionado,
                        'referencia': referenciaController.text.trim(),
                      });
                    },
                    child: Text('Confirmar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(null); // Usuario canceló
                    },
                    child: Text('Cancelar'),
                  ),
                ],
              );
            },
          );
        },
      );

      return resultado;
    }

    final resultado = await _mostrarDialogoEstadoYReferencia();
    if (resultado == null) return; // Canceló

    final pedido = Pedido(
      id: '',
      plato: plato.plato,
      cantidad: cantidad,
      preciobase: plato.precio,
      preciofinal: plato.precio * cantidad,
      estado: resultado['estado']!,
      referencia: resultado['referencia']!,
      tipo: 'ingreso',
      fecha: DateTime.now(),
    );

    await FirebaseHelper.insertarPedido(pedido);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ingreso agregado: ${plato.plato} x $cantidad')),
    );

    controller?.clear();
    // ignore: use_build_context_synchronously
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Ingreso')),
      body: FutureBuilder<List<Plato>>(
        future: _platosFuturos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los platos'));
          }

          final platos = snapshot.data!;
          if (platos.isEmpty) {
            return Center(child: Text('No hay platos registrados.'));
          }
          return ListView.separated(
            itemCount: platos.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, i) {
              final p = platos[i];
              _controladoresCantidad[p.id] ??= TextEditingController();

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  border: Border.all(color: Colors.purple.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FILA SUPERIOR: Cantidad a la izquierda, nombre a la derecha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sección de cantidad
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                final controller =
                                    _controladoresCantidad[p.id]!;
                                int valor = int.tryParse(controller.text) ?? 1;
                                if (valor > 1) {
                                  controller.text = (valor - 1).toString();
                                }
                              },
                            ),
                            SizedBox(
                              width: 40,
                              child: TextField(
                                controller: _controladoresCantidad[p.id],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                final controller =
                                    _controladoresCantidad[p.id]!;
                                int valor = int.tryParse(controller.text) ?? 0;
                                controller.text = (valor + 1).toString();
                              },
                            ),
                          ],
                        ),

                        // Sección de nombre y precio
                        Expanded(
                          child: Text(
                            '${p.plato} - S/ ${p.precio.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Botón "Agregar" centrado y ancho completo
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _agregarIngreso(p),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Agregar'),
                      ),
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
