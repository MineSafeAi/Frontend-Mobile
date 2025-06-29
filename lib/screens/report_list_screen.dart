import 'package:flutter/material.dart';
import 'package:emergentes/models/report_acta_model.dart';
import 'package:emergentes/services/photo_service.dart';
import 'photo_list_screen.dart'; // pantalla para ver las fotos de cada reporte

class ReportListScreen extends StatefulWidget {
  @override
  _ReportListScreenState createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  late Future<List<ReportActa>> _futureReports;

  @override
  void initState() {
    super.initState();
    _futureReports = PhotoService().obtenerReportes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis reportes'), backgroundColor: Colors.brown),
      body: FutureBuilder<List<ReportActa>>(
        future: _futureReports,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final reports = snapshot.data!;
          if (reports.isEmpty) {
            return Center(child: Text('No hay reportes enviados'));
          }
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return ListTile(
                title: Text("Observaciones: ${report.observaciones}"),
                subtitle: Text("Fecha: ${report.fechaCreacion.toLocal().toString().split('.')[0]}"),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoListScreen(reporteActaId: report.id),
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