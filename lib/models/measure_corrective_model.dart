class CorrectiveMeasure {
  final int id;
  final int reporteActaId;
  String contenido;
  String origen;
  DateTime fechaGeneracion;

  CorrectiveMeasure({
    required this.id,
    required this.reporteActaId,
    required this.contenido,
    required this.origen,
    required this.fechaGeneracion,
  });

  factory CorrectiveMeasure.fromJson(Map<String, dynamic> json) {
    return CorrectiveMeasure(
      id: json['id'] ?? 0,
      reporteActaId: json['reporteActaId'] ?? 0,
      contenido: json['contenido'] ?? '',
      origen: json['origen'] ?? '',
      fechaGeneracion: DateTime.tryParse(json['fechaGeneracion'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "reporteActaId": reporteActaId,
    "contenido": contenido,
    "origen": origen,
    "fechaGeneracion": fechaGeneracion.toIso8601String(),
  };
}