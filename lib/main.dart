import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() => runApp(MineSafeAIApp());

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