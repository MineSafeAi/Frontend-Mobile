class ReportActa {
  final int id;
  final int usuarioId;
  final DateTime fechaCreacion;
  final String observaciones;

  ReportActa({
    required this.id,
    required this.usuarioId,
    required this.fechaCreacion,
    required this.observaciones,
  });

  factory ReportActa.fromJson(Map<String, dynamic> json) {
    return ReportActa(
      id: json['id'],
      usuarioId: json['usuarioId'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      observaciones: json['observaciones'] ?? '',
    );
  }
}