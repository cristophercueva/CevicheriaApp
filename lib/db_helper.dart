import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedidos_app/gastos.dart';
import 'package:pedidos_app/pedido.dart';
import 'package:pedidos_app/plato.dart';

class FirebaseHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -------------------- GASTOS --------------------

  static Future<void> insertarGasto(Gastos gasto) async {
    await _db.collection('gastos').add(gasto.toMap(includeId: false));
  }

  static Future<List<Gastos>> obtenerTodosGastos() async {
    final snapshot = await _db.collection('gastos').get();
    return snapshot.docs.map((doc) => Gastos.fromMap(doc.data())).toList();
  }

  static Future<List<Gastos>> obtenerGastosPorFecha(DateTime fecha) async {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(Duration(days: 1));

    final snapshot =
        await _db
            .collection('gastos')
            .where('fecha', isGreaterThanOrEqualTo: inicio.toIso8601String())
            .where('fecha', isLessThan: fin.toIso8601String())
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Gastos(
        id: doc.id, // 🔑 Usa el ID del documento
        nombre: data['nombre'],
        precio: (data['precio'] as num).toDouble(), // por si se guarda como int
        cantidad: data['cantidad'],
        tipo: data['tipo'],
        fecha: DateTime.parse(data['fecha']),
      );
    }).toList();
  }

  static Future<List<Gastos>> obtenerGastosDeHoy() async {
    final hoy = DateTime.now();
    return obtenerGastosPorFecha(hoy);
  }

  static Future<void> actualizarGasto(Gastos gasto) async {
    if (gasto.id == null || gasto.id!.isEmpty) {
      throw Exception("El ID es requerido para actualizar.");
    }

    await FirebaseFirestore.instance
        .collection('gastos')
        .doc(gasto.id)
        .update(gasto.toMap());
  }

  static Future<void> eliminarGasto(String docId) async {
    await _db.collection('gastos').doc(docId).delete();
  }

  // -------------------- PEDIDOS --------------------
  static Future<void> insertarPedido(Pedido pedido) async {
    await _db.collection('pedidos').add(pedido.toMap());
  }

  static Future<List<Pedido>> obtenerTodosPedidos() async {
    final snapshot = await _db.collection('pedidos').get();
    return snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList();
  }

  static Future<List<Pedido>> obtenerPedidosPorFecha(DateTime fecha) async {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(Duration(days: 1));

    final snapshot =
        await _db
            .collection('pedidos')
            .where('fecha', isGreaterThanOrEqualTo: inicio.toIso8601String())
            .where('fecha', isLessThan: fin.toIso8601String())
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Pedido(
        id: doc.id, // 🔑 Usa el ID del documento
        plato: data['plato'],
        cantidad: data['cantidad'],
        preciobase:
            (data['preciobase'] as num).toDouble(), // por si se guarda como int
        preciofinal: (data['preciofinal'] as num).toDouble(), // por si
        estado: data['estado'],
        tipo: data['tipo'],
        referencia: data['referencia'] ?? '', // Maneja caso de referencia nula
        fecha: DateTime.parse(data['fecha']),
      );
    }).toList();
  }

  static Future<void> eliminarPedido(String docId) async {
    await _db.collection('pedidos').doc(docId).delete();
  }

  static Future<void> actualizarEstadoPedido(
    String id,
    String nuevoEstado,
  ) async {
    await FirebaseFirestore.instance.collection('pedidos').doc(id).update({
      'estado': nuevoEstado,
    });
  }

  // -------------------- PLATOS --------------------
  static Future<void> insertarPlato(Plato plato) async {
    await _db.collection('platos').add(plato.toMap());
  }

  static Future<List<Plato>> obtenerTodosPlatos() async {
    final snapshot = await _db.collection('platos').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Plato(
        id: doc.id, // 🔑 Usa el ID del documento
        plato: data['plato'],
        precio: (data['precio'] as num).toDouble(), // por si se guarda como int
        tipo: data['tipo'],
        fecha: DateTime.parse(data['fecha']),
      );
    }).toList();
  }

  static Future<void> eliminarPlato(String docId) async {
    await _db.collection('platos').doc(docId).delete();
  }

  static Future<void> actualizarPlato(Plato plato) async {
    if (plato.id.isEmpty) {
      throw Exception("El ID es requerido para actualizar.");
    }

    await _db.collection('platos').doc(plato.id).update(plato.toMap());
  }
}
