import 'package:flutter/material.dart';
import 'package:pedidos_app/plato.dart';
import 'db_helper.dart';

class RegistrarPlato extends StatefulWidget {
  final Plato? PlatoExistente;
  RegistrarPlato({this.PlatoExistente});
  @override
  _RegistrarPlatoState createState() => _RegistrarPlatoState();
}

class _RegistrarPlatoState extends State<RegistrarPlato> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  void _mostrarTodosLosPlatos() async {
    List<Plato> platos = await FirebaseHelper.obtenerTodosPlatos();
    for (var p in platos) {
      print(
        '🍽️ ${p.plato} - Precio: ${p.precio} -  Fecha: ${p.fecha} - ID: ${p.id}',
      );
    }
  }

  void _guardarPlato() async {
    // Validar campos
    final nombre = _nombreController.text.trim();
    final precio = double.tryParse(_precioController.text.trim());

    if (nombre.isEmpty || precio == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Completa todos los campos')));
      return;
    }
    if (precio <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('El precio debe ser mayor a 0')));
      return;
    }

    final DateTime hoy = DateTime.now();
    final DateTime fechaSinHora = DateTime(hoy.year, hoy.month, hoy.day);

    final nuevoPlato = Plato(
      id: widget.PlatoExistente?.id ?? '',
      plato: nombre,
      precio: precio,
      tipo: 'plato',
      fecha: fechaSinHora,
    );

    if (widget.PlatoExistente != null) {
      await FirebaseHelper.actualizarPlato(nuevoPlato);
    } else {
      await FirebaseHelper.insertarPlato(nuevoPlato);
    }

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.PlatoExistente != null
              ? 'Plato actualizado'
              : 'Plato guardado',
        ),
      ),
    );

    // ignore: use_build_context_synchronously
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    _mostrarTodosLosPlatos();
    // Si hay un gasto existente, precargar los campos
    if (widget.PlatoExistente != null) {
      final plato = widget.PlatoExistente!;
      _nombreController.text = plato.plato;
      _precioController.text = plato.precio.toString();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Plato')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre del Plato'),
            ),
            TextField(
              controller: _precioController,
              decoration: InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarPlato,
              child: Text(
                widget.PlatoExistente != null
                    ? 'Actualizar Plato'
                    : 'Guardar Plato',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
