import 'dart:io';
import 'package:flutter/material.dart';
import '../services/photo_service.dart';
import 'package:emergentes/models/condition_type_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportFormScreen extends StatefulWidget {
  final List<File> selectedImages;

  const ReportFormScreen({required this.selectedImages});

  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  List<_ImageFormData> _formDataList = [];
  String observaciones = "";
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _formDataList = widget.selectedImages.map((file) {
      return _ImageFormData(file: file);
    }).toList();
  }

  Future<void> _submitForms() async {
    setState(() => _loading = true);

    // Recuperar usuarioId (ejemplo si lo guardas en SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuarioId') ?? 0;

    // Preparar lista de fotos
    List<Map<String, dynamic>> fotos = [];

    for (var data in _formDataList) {
      final tipoId = await PhotoService().crearTipoCondicion(data.tipoCondicion);

      if (tipoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creando tipoCondicion: ${data.tipoCondicion}")),
        );
        setState(() => _loading = false);
        return;
      }

      fotos.add({
        "tipoCondicionId": tipoId,
        "ruta": data.file.path.split('/').last,
        "nivelRiesgo": data.nivelRiesgo,
        "descripcion": data.descripcion,
        "fechaCaptura": data.fechaCaptura.toIso8601String(),
        "file": data.file, // se convierte a base64 en el servicio
      });
    }

    final success = await PhotoService().enviarReporteActa(
      usuarioId: usuarioId,
      observaciones: observaciones,
      fotos: fotos,
    );

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reporte enviado correctamente")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al enviar el reporte")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8E7B9),
      appBar: AppBar(title: Text("Llenar datos del reporte"), backgroundColor: Colors.brown),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          TextField(
            decoration: InputDecoration(labelText: "Observaciones generales"),
            onChanged: (value) => observaciones = value,
          ),
          ..._formDataList.map((data) {
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.file(data.file, height: 150, fit: BoxFit.cover),
                    SizedBox(height: 8),
                    TextFormField(
                      initialValue: data.tipoCondicion,
                      onChanged: (value) => data.tipoCondicion = value,
                      decoration: InputDecoration(labelText: "Tipo de condición"),
                    ),
                    DropdownButtonFormField<String>(
                      value: data.nivelRiesgo,
                      onChanged: (value) => setState(() => data.nivelRiesgo = value ?? 'Bajo'),
                      items: ['Bajo', 'Medio', 'Alto'].map((nivel) {
                        return DropdownMenuItem(value: nivel, child: Text(nivel));
                      }).toList(),
                      decoration: InputDecoration(labelText: "Nivel de riesgo"),
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: "Descripción"),
                      onChanged: (value) => data.descripcion = value,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          SizedBox(height: 20),
          _loading
              ? Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
            onPressed: _submitForms,
            icon: Icon(Icons.send),
            label: Text("Enviar"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
          ),
        ],
      ),
    );
  }
}

class _ImageFormData {
  final File file;
  String tipoCondicion;
  String nivelRiesgo;
  String descripcion;
  DateTime fechaCaptura;

  _ImageFormData({
    required this.file,
    this.tipoCondicion = '',
    this.nivelRiesgo = 'Bajo',
    this.descripcion = '',
    DateTime? fechaCaptura,
  }) : fechaCaptura = fechaCaptura ?? DateTime.now();
}