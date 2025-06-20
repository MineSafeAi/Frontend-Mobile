import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'report_form_screen.dart';
import 'report_result_screen.dart';

class ReportSelectionScreen extends StatefulWidget {
  @override
  _ReportSelectionScreenState createState() => _ReportSelectionScreenState();
}

class _ReportSelectionScreenState extends State<ReportSelectionScreen> {
  List<File> _photos = [];
  Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/minesafe_photos';
    final dir = Directory(path);

    if (await dir.exists()) {
      final files = dir
          .listSync()
          .where((f) => f.path.endsWith(".jpg") || f.path.endsWith(".png"))
          .map((e) => File(e.path))
          .toList();

      setState(() {
        _photos = files;
      });
    }
  }

  void _toggleSelection(String path) {
    setState(() {
      if (_selected.contains(path)) {
        _selected.remove(path);
      } else {
        _selected.add(path);
      }
    });
  }

  void _generateReport() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona al menos una imagen')),
      );
      return;
    }

    // Convertimos las rutas seleccionadas a objetos File
    final selectedFiles = _selected.map((path) => File(path)).toList();

    // Navegar a la pantalla de resultados simulados
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportFormScreen(selectedImages: selectedFiles),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar imágenes para informe'),
        backgroundColor: Colors.brown,
      ),
      backgroundColor: Color(0xFFF8E7B9),
      body: _photos.isEmpty
          ? Center(child: Text('No hay imágenes disponibles'))
          : GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final path = _photos[index].path;
          final isSelected = _selected.contains(path);

          return GestureDetector(
            onTap: () => _toggleSelection(path),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  _photos[index],
                  fit: BoxFit.cover,
                ),
                if (isSelected)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 32),
                  )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateReport,
        backgroundColor: Colors.brown,
        icon: Icon(Icons.check),
        label: Text('Generar reporte'),
      ),
    );
  }
}