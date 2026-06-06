class Producto {
  final String? id;
  final String nombre;
  final String? categoria;
  final String unidad;       // ← unidad_medida en backend
  final double precio;       // ← precio_sugerido en backend
  final double stock;        // ← stock_actual en backend (DECIMAL)

  Producto({
    this.id,
    required this.nombre,
    this.categoria,
    required this.unidad,
    required this.precio,
    required this.stock,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      categoria: json['categoria'],
      unidad: json['unidad_medida'],
      precio: double.parse(json['precio_sugerido'].toString()),
      stock: double.parse(json['stock_actual'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      if (categoria != null) 'categoria': categoria,
      'unidad_medida': unidad,
      'precio_sugerido': precio,
      'stock_actual': stock,
    };
  }
}
