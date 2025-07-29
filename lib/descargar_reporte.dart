import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedidos_app/db_helper.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DescargarReporte extends StatefulWidget {
  @override
  _DescargarReporteState createState() => _DescargarReporteState();
}

class _DescargarReporteState extends State<DescargarReporte> {
  DateTime _fechaSeleccionada = DateTime.now();

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _generarReporte() async {
    final fechaFormateada = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada);

    final gastos = await FirebaseHelper.obtenerGastosPorFecha(
      _fechaSeleccionada,
    );
    final pedidos = await FirebaseHelper.obtenerPedidosPorFecha(
      _fechaSeleccionada,
    );

    final excel = Excel.createExcel();

    // Hoja de gastos
    final hojaGastos = excel['Gastos'];
    hojaGastos.appendRow(['Nombre', 'Precio', 'Cantidad', 'Tipo', 'Fecha']);
    for (var g in gastos) {
      hojaGastos.appendRow([
        g.nombre,
        g.precio,
        g.cantidad,
        g.tipo,
        DateFormat('yyyy-MM-dd').format(g.fecha),
      ]);
    }

    // Hoja de pedidos
    final hojaPedidos = excel['Pedidos'];
    hojaPedidos.appendRow([
      'Plato',
      'Cantidad',
      'Precio Base',
      'Precio Final',
      'Tipo',
      'Fecha',
    ]);
    for (var p in pedidos) {
      hojaPedidos.appendRow([
        p.plato,
        p.cantidad,
        p.preciobase,
        p.preciofinal,
        p.tipo,
        DateFormat('yyyy-MM-dd').format(p.fecha),
      ]);
    }
    // ❌ Elimina la hoja vacía por defecto
    excel.delete('Sheet1');
    final bytes = excel.encode();
    final dir = await getExternalStorageDirectory();
    final carpeta = Directory('${dir!.path}/Reportes');
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }

    final archivo = File('${carpeta.path}/Reporte_$fechaFormateada.xlsx');
    await archivo.writeAsBytes(bytes!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📁 Reporte generado: ${archivo.path}'),
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Compartir',
          onPressed: () => Share.shareXFiles([XFile(archivo.path)]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fechaStr = DateFormat('dd/MM/yyyy').format(_fechaSeleccionada);
    return Scaffold(
      appBar: AppBar(title: Text('Descargar Reporte')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Fecha seleccionada: $fechaStr',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text('Seleccionar Fecha'),
              onPressed: _seleccionarFecha,
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.download),
              label: Text('Generar y Descargar Reporte'),
              onPressed: _generarReporte,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
