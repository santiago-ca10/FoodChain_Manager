class Tercero {
  final int id;      
  final String nombre;
  final String tipo;
  final String? telefono;

  Tercero({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.telefono,
  });

  factory Tercero.fromJson(Map<String, dynamic> json) {
    return Tercero(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nombre: json['nombre'],
      tipo: json['tipo'],
      telefono: json['telefono'],
    );
  }
}
