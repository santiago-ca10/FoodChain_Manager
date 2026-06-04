class Movimiento {
  final int? id;
  final String tipo; // 'compra' | 'venta'
  final int cantidad;
  final double precioUnitario;
  final String? notas;
  final int productoId;
  final int terceroId;
  final String? productoNombre;
  final String? terceroNombre;
  final DateTime? fecha;

  Movimiento({
    this.id,
    required this.tipo,
    required this.cantidad,
    required this.precioUnitario,
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
      cantidad: json['cantidad'],
      precioUnitario: double.parse(json['precioUnitario'].toString()),
      notas: json['notas'],
      productoId: json['productoId'] ?? json['Producto']?['id'],
      terceroId: json['terceroId'] ?? json['Tercero']?['id'],
      productoNombre: json['Producto']?['nombre'],
      terceroNombre: json['Tercero']?['nombre'],
      fecha: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      if (notas != null) 'notas': notas,
      'productoId': productoId,
      'terceroId': terceroId,
    };
  }

  double get total => cantidad * precioUnitario;
}
