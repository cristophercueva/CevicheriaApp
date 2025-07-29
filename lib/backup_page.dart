import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'db_helper.dart';
import 'gastos.dart';
import 'pedido.dart';

Future<void> exportarBackupJSON(BuildContext context) async {
  try {
    final gastos = await FirebaseHelper.obtenerTodosGastos();
    final pedidos = await FirebaseHelper.obtenerTodosPedidos();

    final data = {
      "gastos": gastos.map((g) => g.toMap()).toList(),
      "pedidos": pedidos.map((p) => p.toMap()).toList(),
    };

    final jsonString = jsonEncode(data);

    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/respaldo_app_pedidos.json');
    await file.writeAsString(jsonString);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('📁 Respaldo guardado en: ${file.path}')),
    );

    // Compartir
    await Share.shareXFiles([XFile(file.path)], text: 'Respaldo de datos');
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('❌ Error exportando: $e')));
  }
}

Future<void> importarBackupJSON(BuildContext context) async {
  try {
    // Paso 1: Seleccionar archivo
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final contenido = await file.readAsString();

    // Paso 2: Parsear JSON
    final Map<String, dynamic> data = jsonDecode(contenido);

    final gastos =
        (data['gastos'] as List).map((g) => Gastos.fromMap(g)).toList();

    final pedidos =
        (data['pedidos'] as List).map((p) => Pedido.fromMap(p)).toList();

    // Paso 3: Restaurar en base de datos
    for (var g in gastos) {
      await FirebaseHelper.insertarGasto(g);
    }

    for (var p in pedidos) {
      await FirebaseHelper.insertarPedido(p);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('✅ Datos restaurados con éxito')));
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('❌ Error al importar: $e')));
  }
}

class BackupPage extends StatelessWidget {
  const BackupPage({super.key}); // Asegúrate de tener esto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Respaldos y Reportes')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Subir Excel mensual a la nube'),
              onPressed: () {
                // Aquí irá la lógica para seleccionar mes, generar Excel y subirlo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función en desarrollo')),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Exportar respaldo (.json)'),
              onPressed: () {
                exportarBackupJSON(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exportación iniciada')),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Importar respaldo'),
              onPressed: () {
                importarBackupJSON(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Importanción iniciada')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
