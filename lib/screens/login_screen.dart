import 'package:flutter/material.dart';
import 'camera_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8E7B9),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 250),
            const SizedBox(height: 16),
            const SizedBox(height: 32),
            TextField(controller: userController, decoration: InputDecoration(labelText: 'Usuario')),
            const SizedBox(height: 12),
            TextField(controller: passController, decoration: InputDecoration(labelText: 'Contraseña'), obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CameraScreen())),
              child: Text("Ingresar"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            )
          ],
        ),
      ),
    );
  }
}