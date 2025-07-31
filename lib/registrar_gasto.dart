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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF111418)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Registrar Gasto',
          style: TextStyle(
            color: Color(0xFF111418),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputLabel('Nombre del gasto'),
            _customTextField(_nombreController, 'Ej: Pescado fresco'),
            SizedBox(height: 20),
            _inputLabel('Precio'),
            _customTextField(
              _precioController,
              '0.00',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              prefixText: 'S/ ',
            ),
            SizedBox(height: 20),
            _inputLabel('Cantidad'),
            _customTextField(
              _cantidadController,
              'Ej: 5',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3F7FBF),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _guardarGasto,
                child: Text(
                  widget.gastoExistente != null
                      ? 'Actualizar Gasto'
                      : 'Guardar Gasto',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Color.fromARGB(255, 5, 5, 5),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _customTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixText: prefixText,
        prefixStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF3F7FBF), width: 2),
        ),
      ),
      style: TextStyle(fontSize: 16, color: Color(0xFF111418)),
    );
  }
}
