import 'package:flutter/material.dart';
import 'package:emergentes/models/measure_corrective_model.dart';
import 'package:emergentes/models/report_acta_model.dart';
import 'package:emergentes/models/condition_type_model.dart';
import 'package:emergentes/services/photo_service.dart';

class MeasureCorrectiveScreen extends StatefulWidget {
  final int reporteActaId;

  const MeasureCorrectiveScreen({required this.reporteActaId});

  @override
  _MeasureCorrectiveScreenState createState() => _MeasureCorrectiveScreenState();
}

class _MeasureCorrectiveScreenState extends State<MeasureCorrectiveScreen> {
  late Future<CorrectiveMeasure?> _futureMedida;
  late Future<ReportActa?> _futureReport;
  late Future<void> _futureTipoCondiciones;
  Map<int, String> _tipoCondicionMap = {};

  final _contenidoController = TextEditingController();
  final _origenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureMedida = PhotoService().obtenerMedidaPorReporte(widget.reporteActaId);
    _futureReport = PhotoService().obtenerReportePorId(widget.reporteActaId);
    _futureTipoCondiciones = _loadTipoCondiciones();
  }

  Future<void> _loadTipoCondiciones() async {
    final tipos = await PhotoService().obtenerTipoCondiciones();
    _tipoCondicionMap = { for (var tipo in tipos) tipo.id: tipo.nombre };
  }

  Future<void> _guardarCambios(CorrectiveMeasure medida) async {
    medida.contenido = _contenidoController.text;
    medida.origen = _origenController.text;

    final success = await PhotoService().actualizarMedidaCorrectiva(medida);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medida actualizada')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medida Correctiva'), backgroundColor: Colors.brown),
      body: FutureBuilder<void>(
        future: _futureTipoCondiciones,
        builder: (context, tipoSnapshot) {
          if (tipoSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (tipoSnapshot.hasError) {
            return Center(child: Text('Error al cargar tipos de condición'));
          }

          return FutureBuilder<CorrectiveMeasure?>(
            future: _futureMedida,
            builder: (context, medidaSnapshot) {
              if (medidaSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!medidaSnapshot.hasData || medidaSnapshot.data == null) {
                return Center(child: Text('No se encontró medida correctiva'));
              }
              final medida = medidaSnapshot.data!;
              _contenidoController.text = medida.contenido;
              _origenController.text = medida.origen;

              return FutureBuilder<ReportActa?>(
                future: _futureReport,
                builder: (context, reportSnapshot) {
                  if (reportSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!reportSnapshot.hasData || reportSnapshot.data == null) {
                    return Center(child: Text('Error al cargar reporte'));
                  }
                  final report = reportSnapshot.data!;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _contenidoController,
                            decoration: InputDecoration(labelText: 'Contenido'),
                            maxLines: 3,
                          ),
                          TextField(
                            controller: _origenController,
                            decoration: InputDecoration(labelText: 'Origen'),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _guardarCambios(medida),
                            child: Text('Guardar cambios'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                          ),
                          SizedBox(height: 30),
                          Text('Fotos del reporte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 10),
                          ...report.fotos.map((photo) {
                            final tipoNombre = _tipoCondicionMap[photo.tipoCondicionId] ?? 'Desconocido';
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  photo.ruta.isNotEmpty
                                      ? Image.network(photo.ruta)
                                      : Container(
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: Center(child: Icon(Icons.image_not_supported)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Tipo de condición: $tipoNombre"),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("Nivel de riesgo: ${photo.nivelRiesgo}"),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("Descripción: ${photo.descripcion}"),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Text("Fecha captura: ${photo.fechaCaptura}"),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
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