class ReportPhoto {
  final String imagenBase64;
  final int tipoCondicionId;
  final String nivelRiesgo;
  final String descripcion;
  final String fechaCaptura;
  final String ruta;

  ReportPhoto({
    required this.imagenBase64,
    required this.tipoCondicionId,
    required this.nivelRiesgo,
    required this.descripcion,
    required this.fechaCaptura,
    required this.ruta,
  });

  factory ReportPhoto.fromJson(Map<String, dynamic> json) {
    return ReportPhoto(
      imagenBase64: json['imagen'] ?? '',
      tipoCondicionId: json['tipoCondicionId'] ?? 0,
      nivelRiesgo: json['nivelRiesgo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fechaCaptura: json['fechaCaptura'] ?? '',
      ruta: json['ruta'],
    );
  }

  Map<String, dynamic> toJson() => {
    "imagen": imagenBase64,
    "tipoCondicionId": tipoCondicionId,
    "nivelRiesgo": nivelRiesgo,
    "descripcion": descripcion,
    "fechaCaptura": fechaCaptura,
    "ruta": ruta,
  };
}