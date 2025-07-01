import 'package:flutter/material.dart';
import 'package:emergentes/models/report_acta_model.dart';
import 'package:emergentes/services/photo_service.dart';
import 'package:emergentes/models/condition_type_model.dart';

class PhotoListScreen extends StatefulWidget {
  final int reporteActaId;

  const PhotoListScreen({required this.reporteActaId});

  @override
  _PhotoListScreenState createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  late Future<ReportActa?> _futureReport;
  late Future<void> _futureData;
  Map<int, String> _tipoCondicionMap = {};

  final _contenidoController = TextEditingController();
  final _origenController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  Future<void> _loadData() async {
    final tipos = await PhotoService().obtenerTipoCondiciones();
    _tipoCondicionMap = { for (var tipo in tipos) tipo.id: tipo.nombre };
    _futureReport = PhotoService().obtenerReportePorId(widget.reporteActaId);
  }

  Future<void> _guardarMedida() async {
    if (_contenidoController.text.isEmpty || _origenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _loading = true);

    final success = await PhotoService().crearMedidaCorrectiva(
      reporteActaId: widget.reporteActaId,
      contenido: _contenidoController.text,
      origen: _origenController.text,
    );

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Medida correctiva guardada")),
      );
      Navigator.pop(context); // para volver y refrescar la lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar medida")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fotos del reporte'), backgroundColor: Colors.brown),
      body: FutureBuilder<void>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos'));
          }
          return FutureBuilder<ReportActa?>(
            future: _futureReport,
            builder: (context, reportSnapshot) {
              if (reportSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (reportSnapshot.hasError || reportSnapshot.data == null) {
                return Center(child: Text('Error al cargar reporte'));
              }
              final report = reportSnapshot.data!;
              if (report.fotos.isEmpty) {
                return Center(child: Text('No hay fotos'));
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 Formulario Medida Correctiva
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _contenidoController,
                        decoration: InputDecoration(labelText: "Contenido de la medida correctiva"),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _origenController,
                        decoration: InputDecoration(labelText: "Origen"),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: _loading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _guardarMedida,
                        child: Text("Guardar medida correctiva"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      ),
                    ),
                    Divider(),
                    // 📸 Fotos
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: report.fotos.length,
                      itemBuilder: (context, index) {
                        final photo = report.fotos[index];
                        final tipoNombre = _tipoCondicionMap[photo.tipoCondicionId] ?? 'Desconocido';
                        return Card(
                          margin: EdgeInsets.all(10),
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
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}