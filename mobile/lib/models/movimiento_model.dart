class Movimiento {
  final String? id;
  final String tipo;
  final double cantidad;       // DECIMAL en backend
  final double precioUnitario; // precio_unitario en backend
  final double? total;
  final String? notas;
  final String productoId;     // UUID → String
  final String terceroId;      // UUID → String
  final String? productoNombre;
  final String? terceroNombre;
  final DateTime? fecha;

  Movimiento({
    this.id,
    required this.tipo,
    required this.cantidad,
    required this.precioUnitario,
    this.total,
    this.notas,
    required this.productoId,
    required this.terceroId,
    this.productoNombre,
    this.terceroNombre,
    this.fecha,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'],
      tipo: json['tipo'],
      cantidad: double.parse(json['cantidad'].toString()),
      precioUnitario: double.parse(json['precio_unitario'].toString()),
      total: json['total'] != null
          ? double.parse(json['total'].toString())
          : null,
      notas: json['notas'],
      productoId: json['productoId'] ?? json['Producto']?['id'] ?? '',
      terceroId: json['terceroId'] ?? json['Tercero']?['id'] ?? '',
      productoNombre: json['Producto']?['nombre'],
      terceroNombre: json['Tercero']?['nombre'],
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'productoId': productoId,
      'terceroId': terceroId,
      if (notas != null) 'notas': notas,
    };
  }

  double get totalCalculado => total ?? (cantidad * precioUnitario);
}
