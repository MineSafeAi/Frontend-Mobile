import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(MineSafeAIApp());
}

class MineSafeAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MineSafe AI',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: LoginScreen(),
    );
  }
}