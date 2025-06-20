class ConditionType {
  final int id;
  final String nombre;

  ConditionType({required this.id, required this.nombre});

  factory ConditionType.fromJson(Map<String, dynamic> json) {
    return ConditionType(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}