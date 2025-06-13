import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'report_selection_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  void initCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> takePictureAndSave() async {
    if (controller == null || !controller!.value.isInitialized) return;

    await Permission.camera.request();
    await Permission.storage.request();

    final image = await controller!.takePicture();
    final bytes = await image.readAsBytes();

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory customDir = Directory('${appDir.path}/minesafe_photos');

    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
    }

    final String filePath = '${customDir.path}/minesafe_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File file = File(filePath);
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imagen guardada en la app')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8E7B9),
      appBar: AppBar(
        backgroundColor: Color(0xFFF8E7B9),
        title: Text("Cámara"),
      ),
      body: controller == null || !controller!.value.isInitialized
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          CameraPreview(controller!),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Colors.amber,
                onPressed: takePictureAndSave,
                child: Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReportSelectionScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Cámara'),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Informe'),
        ],
      ),
    );
  }
}