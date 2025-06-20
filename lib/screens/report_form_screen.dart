import 'dart:io';
import 'package:emergentes/models/condition_type_model.dart';
import 'package:flutter/material.dart';
import '../services/photo_service.dart';

class ReportFormScreen extends StatefulWidget {
  final List<File> selectedImages;

  const ReportFormScreen({required this.selectedImages});

  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  List<_ImageFormData> _formDataList = [];
  List<ConditionType> _tipoCondiciones = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _formDataList = widget.selectedImages.map((file) {
      return _ImageFormData(file: file);
    }).toList();
  }

  void _submitForms() async {
    for (var data in _formDataList) {
      // Crear tipoCondicion si es necesario
      final tipoId = await PhotoService().crearTipoCondicion(data.tipoCondicion);

      if (tipoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creando tipoCondicion: ${data.tipoCondicion}")),
        );
        return;
      }

      final success = await PhotoService().enviarFotoCondicion(
        tipoCondicionId: tipoId,
        ruta: data.file.path.split('/').last,
        nivelRiesgo: data.nivelRiesgo,
        descripcion: data.descripcion,
        fechaCaptura: data.fechaCaptura,
        imagenFile: data.file,
      );

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al enviar ${data.file.path}")),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Reportes enviados correctamente")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8E7B9),
      appBar: AppBar(title: Text("Llenar datos del reporte"), backgroundColor: Colors.brown),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: _formDataList.length,
        itemBuilder: (context, index) {
          final data = _formDataList[index];
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
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForms,
        backgroundColor: Colors.brown,
        label: Text("Enviar"),
        icon: Icon(Icons.send),
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