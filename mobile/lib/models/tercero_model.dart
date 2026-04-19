class Tercero {
  final String id;
  final String nombre;
  final String tipo;
  final String? telefono;

  Tercero({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.telefono,
  });

  // Esta función convierte el JSON que viene del Backend en un objeto de Flutter
  factory Tercero.fromJson(Map<String, dynamic> json) {
    return Tercero(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      telefono: json['telefono'],
    );
  }
}