import 'package:cloud_firestore/cloud_firestore.dart';

class Gastos {
  final String? id;
  final String nombre;
  final double precio;
  final String cantidad;
  final String tipo;
  final DateTime fecha;

  Gastos({
    this.id,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.tipo,
    required this.fecha,
  });

  /// Convierte el objeto a un mapa para Firestore
  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = {
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      'tipo': tipo,
      'fecha': fecha.toIso8601String(),
    };

    return map;
  }

  /// Crea un objeto desde un mapa
  factory Gastos.fromMap(Map<String, dynamic> map, {String? id}) {
    return Gastos(
      id: id,
      nombre: map['nombre'] ?? '',
      precio:
          (map['precio'] is int)
              ? (map['precio'] as int).toDouble()
              : map['precio'] ?? 0.0,
      cantidad: map['cantidad'] ?? '',
      tipo: map['tipo'] ?? '',
      fecha: DateTime.parse(map['fecha']),
    );
  }

  /// Crea un objeto desde un DocumentSnapshot
  factory Gastos.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Gastos.fromMap(data, id: doc.id);
  }
}
