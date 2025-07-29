class Plato {
  final String id;
  final String plato;
  final double precio;
  final String tipo;
  final DateTime fecha;

  Plato({
    required this.id,
    required this.plato,
    required this.precio,
    required this.tipo,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plato': plato,
      'precio': precio,
      'tipo': tipo,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Plato.fromMap(Map<String, dynamic> map) {
    return Plato(
      id: map['id'],
      plato: map['plato'],
      precio: map['precio'],
      tipo: map['tipo'],
      fecha: DateTime.parse(map['fecha']),
    );
  }
}
