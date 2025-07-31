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
import 'package:url_launcher/url_launcher.dart';
import 'db_helper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';

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
                    onPressed: () async {
                      final url = Uri.parse(
                        'https://github.com/cristophercueva/CevicheriaApp/releases/download/v1.0.0/app-release.apk',
                      );

                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        // Manejo de error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No se pudo abrir el enlace')),
                        );
                      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Cevicheria Los Gorditos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hoy, ${_formatearFechaActual()}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FutureBuilder<Map<String, double>>(
                future: _obtenerResumenHoy(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;
                  final gastos = data['gastos']!;
                  final ingresos = data['ingresos']!;
                  final ganancia = data['ganancia']!;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildResumenItem('Total Gastos', gastos),
                      _buildResumenItem('Ganancias', ganancia),
                      _buildResumenItem('Total Ingresos', ingresos),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Acciones Rápidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  _botonAccionConIcono(
                    Icons.add,
                    'Registrar Gasto',
                    () => _navegarA(context, RegistrarGasto()),
                  ),
                  _botonAccionConIcono(
                    Icons.add,
                    'Registrar Ingreso',
                    () => _navegarA(context, RegistrarIngreso()),
                  ),
                  _botonAccionConIcono(
                    Icons.edit,
                    'Editar Gastos',
                    () => _navegarA(context, ListadoGastos()),
                  ),
                  _botonAccionConIcono(
                    Icons.edit,
                    'Editar Ingresos',
                    () => _navegarA(context, ListadoPedidos()),
                  ),
                  _botonAccionConIcono(
                    Icons.restaurant_menu,
                    'Registrar Plato',
                    () => _navegarA(context, RegistrarPlato()),
                  ),
                  _botonAccionConIcono(
                    Icons.restaurant_menu,
                    'Editar Plato',
                    () => _navegarA(context, ListadoPlatos()),
                  ),
                  _botonAccionConIcono(
                    Icons.download,
                    'Descargar Reporte',
                    () => _navegarA(context, DescargarReporte()),
                  ),
                  _botonAccionConIcono(
                    Icons.code,
                    'Generate Scripts',
                    () => _navegarA(context, BackupPage()),
                    spanTwo: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItem(String label, double value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
        SizedBox(height: 4),
        Text(
          'S/ ${value.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _botonAccionConIcono(
    IconData icon,
    String texto,
    VoidCallback onPressed, {
    bool spanTwo = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFE0E7FF),
              child: Icon(icon, color: Color(0xFF0C7FF2)),
            ),
            SizedBox(height: 8),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _navegarA(BuildContext context, Widget pantalla) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
    if (result == true) setState(() {});
  }
}
