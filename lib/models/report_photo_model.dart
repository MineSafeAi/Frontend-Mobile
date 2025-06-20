class ReportPhoto {
  final String imagenBase64;
  final int tipoCondicionId;
  final String nivelRiesgo;
  final String descripcion;
  final String fechaCaptura;

  ReportPhoto({
    required this.imagenBase64,
    required this.tipoCondicionId,
    required this.nivelRiesgo,
    required this.descripcion,
    required this.fechaCaptura,
  });

  Map<String, dynamic> toJson() => {
    "imagen": imagenBase64,
    "tipoCondicionId": tipoCondicionId,
    "nivelRiesgo": nivelRiesgo,
    "descripcion": descripcion,
    "fechaCaptura": fechaCaptura,
  };
}