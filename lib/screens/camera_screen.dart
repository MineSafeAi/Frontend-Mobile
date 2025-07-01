import 'dart:io';
import 'dart:typed_data';
import 'package:emergentes/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'report_selection_screen.dart';
import 'report_list_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  int _currentIndex = 0;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.high);
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndSave() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    await Permission.camera.request();
    await Permission.storage.request();

    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuarioId');

    if (usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró el usuario, inicia sesión de nuevo.')),
      );
      return;
    }

    final image = await _controller!.takePicture();
    final bytes = await image.readAsBytes();

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory customDir = Directory('${appDir.path}/minesafe_photos/usuario_$usuarioId');

    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
    }

    final String filePath = '${customDir.path}/minesafe_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File file = File(filePath);
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imagen guardada en la galería')),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Widget _buildCameraView() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              backgroundColor: Colors.amber,
              onPressed: _takePictureAndSave,
              child: Icon(Icons.camera_alt),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildCameraView(),
      ReportSelectionScreen(),
      ReportListScreen(),
      // Pantalla vacía para logout (no se usa, se intercepta el tap)
      Center(child: Text('Cerrando sesión...')),
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF8E7B9),
      body: _currentIndex == 3
          ? Center(child: CircularProgressIndicator())
          : screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 3) {
            await _logout();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Cámara'),
          BottomNavigationBarItem(icon: Icon(Icons.create), label: 'Informe'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Reportes'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Cerrar Sesión'),
        ],
      ),
    );
  }
}