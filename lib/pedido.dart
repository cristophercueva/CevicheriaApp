class Pedido {
  final String id;
  final String plato;
  final int cantidad;
  final double preciobase;
  final double preciofinal;
  final String estado;
  final String referencia;
  final String tipo;
  final DateTime fecha;

  Pedido({
    required this.id,
    required this.plato,
    required this.cantidad,
    required this.preciobase,
    required this.preciofinal,
    required this.estado,
    required this.referencia,
    required this.tipo,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plato': plato,
      'cantidad': cantidad,
      'preciobase': preciobase,
      'preciofinal': preciofinal,
      'estado': estado,
      'referencia': referencia,
      'tipo': tipo,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      plato: map['plato'],
      cantidad: map['cantidad'],
      preciobase: map['preciobase'],
      preciofinal: map['preciofinal'],
      estado: map['estado'],
      referencia: map['referencia'] ?? '', // Maneja caso de referencia nula
      tipo: map['tipo'],
      fecha: DateTime.parse(map['fecha']),
    );
  }
}
