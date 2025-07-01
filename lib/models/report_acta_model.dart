import 'package:emergentes/models/report_photo_model.dart';

class ReportActa {
  final int id;
  final int usuarioId;
  final String observaciones;
  final DateTime fechaCreacion;
  final List<ReportPhoto> fotos;

  ReportActa({
    required this.id,
    required this.usuarioId,
    required this.observaciones,
    required this.fechaCreacion,
    required this.fotos,
  });

  factory ReportActa.fromJson(Map<String, dynamic> json) {
    final fotosList = (json['fotos'] as List<dynamic>?)
        ?.map((e) => ReportPhoto.fromJson(e))
        .toList() ?? [];

    return ReportActa(
      id: json['id'],
      usuarioId: json['usuarioId'],
      observaciones: json['observaciones'] ?? '',
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fotos: fotosList,
    );
  }
}