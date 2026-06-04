class Producto {
  final int? id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final int stock;
  final String unidad;

  Producto({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.stock,
    required this.unidad,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: double.parse(json['precio'].toString()),
      stock: json['stock'],
      unidad: json['unidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'unidad': unidad,
    };
  }
}
