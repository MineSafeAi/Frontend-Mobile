import 'package:emergentes/screens/measure_corrective_screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emergentes/models/report_acta_model.dart';
import 'package:emergentes/services/photo_service.dart';
import 'package:open_file/open_file.dart';
import '../models/measure_corrective_model.dart';
import 'package:excel/excel.dart';
import 'package:emergentes/models/report_photo_model.dart';
import 'photo_list_screen.dart';
import 'dart:io';

class ReportListScreen extends StatefulWidget {
  @override
  _ReportListScreenState createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  late Future<List<ReportActa>> _futureReports;
  late Future<List<CorrectiveMeasure>> _futureMeasures;

  @override
  void initState() {
    super.initState();
    _futureReports = _loadMyReports();
    _futureMeasures = PhotoService().obtenerMedidasCorrectivas();
  }

  Future<List<ReportActa>> _loadMyReports() async {
    final allReports = await PhotoService().obtenerReportesConFotos();
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuarioId');

    if (usuarioId == null) {
      return [];
    }

    // Filtrar solo reportes del usuario
    final myReports = allReports.where((report) => report.usuarioId == usuarioId).toList();
    return myReports;
  }

  Future<void> generarExcel(List<ReportActa> reports, List<CorrectiveMeasure> measures) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Reportes'];

    // Encabezados
    sheet.appendRow([
      TextCellValue('Usuario'),
      TextCellValue('Observaciones'),
      TextCellValue('Ruta'),
      TextCellValue('Tipo de condición'),
      TextCellValue('Nivel de riesgo'),
      TextCellValue('Descripción'),
      TextCellValue('Medida Correctiva'),
      TextCellValue('Fecha'),
    ]);

    // Obtener nombre del usuario desde SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final nombreUsuario = prefs.getString("nombres") ?? "Desconocido";

    // Obtener tipos de condición
    final tipos = await PhotoService().obtenerTipoCondiciones();
    final tipoCondicionMap = { for (var tipo in tipos) tipo.id: tipo.nombre };

    // Crear mapa rápido para las medidas correctivas
    final medidasMap = {
      for (var medida in measures) medida.reporteActaId: medida.contenido
    };

    for (final report in reports) {
      final medida = medidasMap[report.id] ?? '';

      if (report.fotos.isEmpty) {
        sheet.appendRow([
          TextCellValue(nombreUsuario),
          TextCellValue(report.observaciones ?? ''),
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue(medida),
          TextCellValue(report.fechaCreacion.toString()),
        ]);
      } else {
        for (final foto in report.fotos) {
          final tipoNombre = tipoCondicionMap[foto.tipoCondicionId] ?? 'Desconocido';

          sheet.appendRow([
            TextCellValue(nombreUsuario),
            TextCellValue(report.observaciones ?? ''),
            TextCellValue(foto.ruta ?? ''),
            TextCellValue(tipoNombre),
            TextCellValue(foto.nivelRiesgo ?? ''),
            TextCellValue(foto.descripcion ?? ''),
            TextCellValue(medida),
            TextCellValue(foto.fechaCaptura ?? ''),
          ]);
        }
      }
    }

    final dir = await getExternalStorageDirectory();
    final String outputFile = "${dir!.path}/reportes.xlsx";

    final File file = File(outputFile)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    print("Archivo Excel generado en: $outputFile");
    final result = await OpenFile.open(outputFile);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel generado exitosamente')),
    );

    print("Resultado al abrir: ${result.message}");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis reportes'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              final reports = await _futureReports;
              final measures = await _futureMeasures;

              await generarExcel(reports, measures);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Excel generado exitosamente')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ReportActa>>(
        future: _futureReports,
        builder: (context, snapshotReports) {
          if (snapshotReports.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshotReports.hasError) {
            return Center(child: Text('Error: ${snapshotReports.error}'));
          }

          final reports = snapshotReports.data!;

          return FutureBuilder<List<CorrectiveMeasure>>(
            future: _futureMeasures,
            builder: (context, snapshotMeasures) {
              if (snapshotMeasures.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshotMeasures.hasError) {
                return Center(child: Text('Error: ${snapshotMeasures.error}'));
              }

              final measures = snapshotMeasures.data!;

              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  final hasMeasure = measures.any((m) => m.reporteActaId == report.id);

                  return ListTile(
                    title: Text("Observaciones: ${report.observaciones}"),
                    subtitle: Text("Fecha: ${report.fechaCreacion.toLocal().toString().split('.')[0]}"),
                    trailing: Icon(hasMeasure ? Icons.visibility : Icons.arrow_forward),
                    onTap: () async {
                      if (hasMeasure) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MeasureCorrectiveScreen(reporteActaId: report.id)),
                        );
                        setState(() {
                          _futureReports = _loadMyReports();
                          _futureMeasures = PhotoService().obtenerMedidasCorrectivas();
                        });
                      } else {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PhotoListScreen(reporteActaId: report.id)),
                        );
                        setState(() {
                          _futureReports = _loadMyReports();
                          _futureMeasures = PhotoService().obtenerMedidasCorrectivas();
                        });
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}