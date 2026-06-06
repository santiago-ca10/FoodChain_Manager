class Tercero {
  final String id;
  final String nombre;
  final String tipo;
  final String? telefono;
  final String? direccion;

  Tercero({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.telefono,
    this.direccion,
  });

  factory Tercero.fromJson(Map<String, dynamic> json) {
    return Tercero(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      telefono: json['telefono'],
      direccion: json['direccion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      if (telefono != null) 'telefono': telefono,
      if (direccion != null) 'direccion': direccion,
    };
  }
}
