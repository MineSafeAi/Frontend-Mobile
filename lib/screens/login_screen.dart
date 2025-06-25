import 'package:flutter/material.dart';
import 'package:emergentes/services/auth_service.dart';
import 'package:emergentes/screens/camera_screen.dart';
import 'package:emergentes/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    final email = userController.text.trim();
    final password = passController.text;

    final userData = await AuthService().login(email, password);
    setState(() => _loading = false);

    if (userData != null) {
      final token = userData['data']['token'];
      print('🔐 Token recibido: $token');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CameraScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo o contraseña incorrectos')),
      );
    }
  }

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
            const SizedBox(height: 32),
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              child: Text("Ingresar"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
              child: Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}