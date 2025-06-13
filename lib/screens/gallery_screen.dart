import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'camera_screen.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<AssetEntity> _images = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  Future<void> _loadGalleryImages() async {
    setState(() {
      _loading = true;
    });

    final PermissionState permission = await PhotoManager.requestPermissionExtend();

    if (permission.isAuth) {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isNotEmpty) {
        final recent = albums.first;
        final images = await recent.getAssetListPaged(page: 0, size: 100);

        setState(() {
          _images = images;
          _loading = false;
        });
      } else {
        setState(() {
          _images = [];
          _loading = false;
        });
      }
    } else if (permission == PermissionState.limited) {
      setState(() => _loading = false);
    } else if (permission == PermissionState.denied) {
      setState(() => _loading = false);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Permiso requerido'),
          content: Text(
            'Para ver las fotos necesitas permitir acceso a las imágenes. Ve a Configuración para habilitarlo.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                PhotoManager.openSetting();
              },
              child: Text('Abrir configuración'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8E7B9),
      appBar: AppBar(
        title: Text("Galería"),
        backgroundColor: Color(0xFFF8E7B9),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _images.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No se encontraron imágenes", style: TextStyle(fontSize: 18)),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return FutureBuilder<Uint8List?>(
            future: _images[index].thumbnailDataWithSize(
              ThumbnailSize(200, 200),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return GestureDetector(
                  onTap: () async {
                    final file = await _images[index].file;
                    if (file != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ImageFullScreen(filePath: file.path),
                        ),
                      );
                    }
                  },
                  child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                );
              } else {
                return Container(color: Colors.grey[300]);
              }
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CameraScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Cámara'),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Informe'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: Icon(Icons.refresh),
        onPressed: _loadGalleryImages,
      ),
    );
  }
}

class ImageFullScreen extends StatelessWidget {
  final String filePath;

  const ImageFullScreen({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(child: Image.file(File(filePath))),
    );
  }
}