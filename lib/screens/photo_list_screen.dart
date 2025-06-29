import 'package:flutter/material.dart';
import 'package:emergentes/models/report_photo_model.dart';
import 'package:emergentes/services/photo_service.dart';
import 'dart:convert';

class PhotoListScreen extends StatefulWidget {
  final int reporteActaId;

  const PhotoListScreen({required this.reporteActaId});

  @override
  _PhotoListScreenState createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  late Future<List<ReportPhoto>> _futurePhotos;

  @override
  void initState() {
    super.initState();
    _futurePhotos = PhotoService().obtenerFotosPorReporte(widget.reporteActaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fotos del reporte'), backgroundColor: Colors.brown),
      body: FutureBuilder<List<ReportPhoto>>(
        future: _futurePhotos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final photos = snapshot.data!;
          if (photos.isEmpty) {
            return Center(child: Text('No hay fotos'));
          }
          return ListView.builder(
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    if (photo.imagenBase64.isNotEmpty)
                      Image.memory(base64Decode(photo.imagenBase64)),
                    ListTile(
                      title: Text("Descripción: ${photo.descripcion}"),
                      subtitle: Text("Nivel riesgo: ${photo.nivelRiesgo}"),
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