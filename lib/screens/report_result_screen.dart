import 'dart:io';
import 'package:flutter/material.dart';

class ReportResultScreen extends StatelessWidget {
  final List<File> selectedImages;

  const ReportResultScreen({required this.selectedImages});

  // Simulación de análisis de imagen con datos falsos
  Map<String, String> simulateMLAnalysis(File image) {
    return {
      'Nombre': 'Mina ${image.path.hashCode % 1000}',
      'Tipo': 'Subterránea',
      'Nivel': 'Nivel ${1 + image.path.hashCode % 5}',
      'Descripción': 'Descripción generada para la imagen',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reporte generado")),
      backgroundColor: const Color(0xFFF8E7B9),
      body: ListView.builder(
        itemCount: selectedImages.length,
        itemBuilder: (context, index) {
          final image = selectedImages[index];
          final analysis = simulateMLAnalysis(image);

          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.file(image, height: 200, width: double.infinity, fit: BoxFit.cover),
                  const SizedBox(height: 12),
                  ...analysis.entries.map((entry) => Text(
                    "${entry.key}: ${entry.value}",
                    style: const TextStyle(fontSize: 16),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}