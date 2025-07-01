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
  List<ConditionType> _tiposCondicion = [];

  @override
  void initState() {
    super.initState();
    _formDataList = widget.selectedImages.map((file) {
      return _ImageFormData(file: file);
    }).toList();

    _loadTiposCondicion();
  }

  Future<void> _loadTiposCondicion() async {
    final tipos = await PhotoService().obtenerTipoCondiciones();
    setState(() {
      _tiposCondicion = tipos;
    });
  }

  Future<void> _submitForms() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuarioId') ?? 0;

    List<Map<String, dynamic>> fotos = [];

    for (var data in _formDataList) {
      if (data.tipoCondicionId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Selecciona el tipo de condición para todas las fotos")),
        );
        setState(() => _loading = false);
        return;
      }

      fotos.add({
        "tipoCondicionId": data.tipoCondicionId,
        "ruta": data.file.path.split('/').last,
        "nivelRiesgo": data.nivelRiesgo,
        "descripcion": data.descripcion,
        "fechaCaptura": data.fechaCaptura.toIso8601String(),
        "file": data.file, // se convierte a base64 en el servicio
      });
    }

    final success = await PhotoService().enviarReporteActa(
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
      body: _tiposCondicion.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
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
                    DropdownButtonFormField<int>(
                      value: data.tipoCondicionId,
                      onChanged: (value) => setState(() => data.tipoCondicionId = value),
                      items: _tiposCondicion.map((tipo) {
                        return DropdownMenuItem(
                          value: tipo.id,
                          child: Text(tipo.nombre),
                        );
                      }).toList(),
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
  int? tipoCondicionId;
  String nivelRiesgo;
  String descripcion;
  DateTime fechaCaptura;

  _ImageFormData({
    required this.file,
    this.tipoCondicionId,
    this.nivelRiesgo = 'Bajo',
    this.descripcion = '',
    DateTime? fechaCaptura,
  }) : fechaCaptura = fechaCaptura ?? DateTime.now();
}