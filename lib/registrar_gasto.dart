import 'package:flutter/material.dart';
import 'package:pedidos_app/gastos.dart';
import 'db_helper.dart';

class RegistrarGasto extends StatefulWidget {
  final Gastos? gastoExistente;
  RegistrarGasto({this.gastoExistente});
  @override
  _RegistrarGastoState createState() => _RegistrarGastoState();
}

class _RegistrarGastoState extends State<RegistrarGasto> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

  void _guardarGasto() async {
    // Validar campos
    final nombre = _nombreController.text.trim();
    final precio = double.tryParse(_precioController.text.trim());
    final cantidad = _cantidadController.text.trim();

    if (nombre.isEmpty || precio == null || cantidad.isEmpty) {
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

    final nuevoGasto = Gastos(
      id: widget.gastoExistente?.id ?? '',
      nombre: nombre,
      precio: precio,
      cantidad: cantidad,
      tipo: 'gastos',
      fecha: fechaSinHora,
    );

    if (widget.gastoExistente != null) {
      await FirebaseHelper.actualizarGasto(nuevoGasto);
    } else {
      await FirebaseHelper.insertarGasto(nuevoGasto);
    }

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.gastoExistente != null
              ? 'Gasto actualizado'
              : 'Gasto guardado',
        ),
      ),
    );

    // ignore: use_build_context_synchronously
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    // Si hay un gasto existente, precargar los campos
    if (widget.gastoExistente != null) {
      final gasto = widget.gastoExistente!;
      _nombreController.text = gasto.nombre;
      _precioController.text = gasto.precio.toString();
      _cantidadController.text = gasto.cantidad;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre del gasto'),
            ),
            TextField(
              controller: _precioController,
              decoration: InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _cantidadController,
              decoration: InputDecoration(labelText: 'Cantidad'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarGasto,
              child: Text(
                widget.gastoExistente != null
                    ? 'Actualizar Gasto'
                    : 'Guardar Gasto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
