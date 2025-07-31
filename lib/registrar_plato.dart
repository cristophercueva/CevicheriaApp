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
          'Registrar Plato',
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
            _inputLabel('Nombre del Plato'),
            _customTextField(_nombreController, 'Ej: Ceviche Mixto'),
            SizedBox(height: 20),
            _inputLabel('Precio'),
            _customTextField(
              _precioController,
              '0.00',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              prefixText: 'S/ ',
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
                onPressed: _guardarPlato,
                child: Text(
                  widget.PlatoExistente != null
                      ? 'Actualizar Plato'
                      : 'Guardar Plato',
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
        color: Color(0xFF637488),
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
        prefixIcon:
            prefixText != null
                ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Text(
                    prefixText,
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16,
                    ),
                  ),
                )
                : null,
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
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
