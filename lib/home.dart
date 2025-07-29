import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pedidos_app/ListadoGastos.dart';
import 'package:pedidos_app/ListadoPedidos.dart';
import 'package:pedidos_app/ListadoPlatos.dart';
import 'package:pedidos_app/backup_page.dart';
import 'package:pedidos_app/descargar_reporte.dart';
import 'package:pedidos_app/registrar_gasto.dart';
import 'package:pedidos_app/registrar_ingreso.dart';
import 'package:pedidos_app/registrar_plato.dart';
import 'db_helper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class RegistroPedidosApp extends StatefulWidget {
  @override
  _RegistroPedidosAppState createState() => _RegistroPedidosAppState();
}

Future<bool> necesitaActualizar() async {
  final versionDoc =
      await FirebaseFirestore.instance
          .collection('config')
          .doc('version_app')
          .get();

  final minVersion = versionDoc.data()?['min_version'] ?? '1.0.0';
  final info = await PackageInfo.fromPlatform();
  final currentVersion = info.version;

  return _compararVersiones(currentVersion, minVersion);
}

bool _compararVersiones(String actual, String minima) {
  final a = actual.split('.').map(int.parse).toList();
  final m = minima.split('.').map(int.parse).toList();

  for (int i = 0; i < m.length; i++) {
    if (a[i] < m[i]) return true;
    if (a[i] > m[i]) return false;
  }
  return false;
}

class _RegistroPedidosAppState extends State<RegistroPedidosApp> {
  bool _ignorarActualizacion = false;

  String _formatearFechaActual() {
    initializeDateFormatting('es_PE', null); // Perú o 'es_ES'
    final ahora = DateTime.now();
    final formatter = DateFormat("EEEE d 'de' MMMM 'del' y", 'es');
    return formatter.format(ahora)[0].toUpperCase() +
        formatter.format(ahora).substring(1);
  }

  Future<double> _obtenerTotalIngresosHoy() async {
    final hoyp = DateTime.now();
    final todosp = await FirebaseHelper.obtenerTodosPedidos();

    //print('Pedidos encontrados: ${todosp.length}');

    final pedidosHoy = todosp.where(
      (p) =>
          p.fecha.year == hoyp.year &&
          p.fecha.month == hoyp.month &&
          p.fecha.day == hoyp.day,
    );

    double totalp = 0.0;
    for (var p in pedidosHoy) {
      totalp += p.preciofinal;
    }

    return totalp;
  }

  Future<Map<String, double>> _obtenerResumenHoy() async {
    final gastos = await _obtenerTotalGastosHoy();
    final ingresos = await _obtenerTotalIngresosHoy();
    return {
      'gastos': gastos,
      'ingresos': ingresos,
      'ganancia': ingresos - gastos,
    };
  }

  Future<double> _obtenerTotalGastosHoy() async {
    final hoy = DateTime.now();
    final todos = await FirebaseHelper.obtenerTodosGastos();
    //print('gASTOS encontrados: ${todos.length}');
    final gastosHoy = todos.where(
      (g) =>
          g.fecha.year == hoy.year &&
          g.fecha.month == hoy.month &&
          g.fecha.day == hoy.day,
    );

    double total = 0.0;
    for (var g in gastosHoy) {
      total += g.precio;
    }

    return total;
  }

  @override
  void initState() {
    super.initState();
    verificarVersion();
  }

  void verificarVersion() async {
    if (_ignorarActualizacion)
      return; // 👈 No volver a mostrar si ya dijo "ver más tarde"

    final actualizar = await necesitaActualizar();
    if (actualizar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => AlertDialog(
                title: Text('Actualización requerida'),
                content: Text(
                  'Tu versión está desactualizada. Por favor actualiza.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Aquí iría el link a tu APK
                      // launch('https://tuservidor.com/app.apk');
                    },
                    child: Text('Actualizar'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _ignorarActualizacion =
                            true; // 👈 Marca que ya no muestre más
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Ver más tarde'),
                  ),
                ],
              ),
        );
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cevicheria Los Gorditos')),
      body: Column(
        children: [
          // CONTENEDOR SUPERIOR CON FECHA Y TOTALES
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatearFechaActual(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 10),
                FutureBuilder<Map<String, double>>(
                  future: _obtenerResumenHoy(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Text('Cargando...');

                    final data = snapshot.data!;
                    final gastos = data['gastos']!;
                    final ingresos = data['ingresos']!;
                    final ganancia = data['ganancia']!;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Gastos'),
                            Text('S/ ${gastos.toStringAsFixed(2)}'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Ganancia'),
                            Text('S/ ${ganancia.toStringAsFixed(2)}'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Total Ingresos'),
                            Text('S/ ${ingresos.toStringAsFixed(2)}'),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // CONTENEDOR DE BOTONES
          Expanded(
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _botonAccion('Registrar Gasto', () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegistrarGasto()),
                    );

                    if (result == true) {
                      setState(() {});
                    }
                  }),

                  _botonAccion('Registrar Ingreso', () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegistrarIngreso()),
                    );
                    if (result == true) {
                      setState(() {});
                    }
                  }),
                  _botonAccion('Editar Gasto', () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ListadoGastos()),
                    );
                    if (result == true) {
                      setState(() {});
                    }
                  }),
                  _botonAccion('Editar Ingreso', () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ListadoPedidos()),
                    );
                    if (result == true) {
                      setState(() {});
                    }
                  }),

                  _botonAccion('Registrar Plato', () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegistrarPlato()),
                    );

                    if (result == true) {
                      setState(() {});
                    }
                  }),
                  _botonAccion('Editar Plato', () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ListadoPlatos()),
                    );

                    if (result == true) {
                      setState(() {});
                    }
                  }),
                  _botonAccion('Descargar Reporte', () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DescargarReporte()),
                    );

                    if (result == true) {
                      setState(() {});
                    }
                  }),
                  _botonAccion('Generar Scripts', () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BackupPage()),
                    );

                    if (result == true) {
                      setState(() {});
                    }
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET REUTILIZABLE PARA BOTONES
  Widget _botonAccion(String texto, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
