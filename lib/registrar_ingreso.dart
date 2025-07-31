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

    // Mostrar diálogo para estado y referencia
    Future<Map<String, String>?> _mostrarDialogoEstadoYReferencia() async {
      String estadoSeleccionado = 'Pendiente';
      TextEditingController referenciaController = TextEditingController();
      bool mostrarError = false;

      return await showModalBottomSheet<Map<String, String>>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 16,
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicador superior
                    Container(
                      width: 40,
                      height: 5,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    Text(
                      'Información del pedido',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Estado',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap:
                                () => setState(
                                  () => estadoSeleccionado = 'Pendiente',
                                ),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    estadoSeleccionado == 'Pendiente'
                                        ? Color(0xFF3F7FBF)
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Text(
                                'Pendiente',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      estadoSeleccionado == 'Pendiente'
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap:
                                () => setState(
                                  () => estadoSeleccionado = 'Pagado',
                                ),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    estadoSeleccionado == 'Pagado'
                                        ? Color(0xFF3F7FBF)
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Text(
                                'Pagado',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      estadoSeleccionado == 'Pagado'
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Referencia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    TextField(
                      controller: referenciaController,
                      decoration: InputDecoration(
                        hintText: 'Ingrese referencia',
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: mostrarError ? Colors.red : Colors.grey,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color:
                                mostrarError
                                    ? Colors.red
                                    : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color:
                                mostrarError ? Colors.red : Color(0xFF3F7FBF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    if (mostrarError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Este campo es obligatorio',
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ),
                    SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(null);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFE0E7FF),
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (referenciaController.text.trim().isEmpty) {
                                setState(() => mostrarError = true);
                                return;
                              }
                              Navigator.of(context).pop({
                                'estado': estadoSeleccionado,
                                'referencia': referenciaController.text.trim(),
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3F7FBF),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Confirmar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                  ],
                );
              },
            ),
          );
        },
      );
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
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Registrar Ingreso',
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
            return Center(child: Text('Error al cargar los platos'));
          }

          final platos = snapshot.data!;
          if (platos.isEmpty) {
            return Center(child: Text('No hay platos registrados.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: platos.length,
            itemBuilder: (context, i) {
              final p = platos[i];
              _controladoresCantidad[p.id] ??= TextEditingController(text: "1");

              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y precio
                    Text(
                      p.plato,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111418),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'S/ ${p.precio.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 14, color: Color(0xFF637488)),
                    ),
                    SizedBox(height: 12),

                    // Cantidad y botón agregar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Contador de cantidad
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF2F4F8),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  final controller =
                                      _controladoresCantidad[p.id]!;
                                  int valor =
                                      int.tryParse(controller.text) ?? 1;
                                  if (valor > 1) {
                                    controller.text = (valor - 1).toString();
                                  }
                                },
                                iconSize: 20,
                                color: Color(0xFF3F7FBF),
                              ),
                              SizedBox(
                                width: 36,
                                child: TextField(
                                  controller: _controladoresCantidad[p.id],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  final controller =
                                      _controladoresCantidad[p.id]!;
                                  int valor =
                                      int.tryParse(controller.text) ?? 0;
                                  controller.text = (valor + 1).toString();
                                },
                                iconSize: 20,
                                color: Color(0xFF3F7FBF),
                              ),
                            ],
                          ),
                        ),

                        // Botón Agregar
                        OutlinedButton(
                          onPressed: () => _agregarIngreso(p),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF3F7FBF),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text('Agregar'),
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
    );
  }
}
