import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emergentes/enviroments/env.dart';

class AuthService {
  Future<bool> register({
    required String nombres,
    required String dni,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${Env.baseUrl}/register');

    try {
      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombres': nombres,
          'dni': dni,
          'email': email,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 10)); // Limita el tiempo de espera

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('❌ Error en registro (status): ${response.statusCode}');
        print('❗ Respuesta del servidor: ${response.body}');
        return false;
      }
    } on SocketException {
      print('🚫 Error de red: No se pudo conectar al servidor');
      return false;
    } on TimeoutException {
      print('⏳ Error: El servidor tardó demasiado en responder');
      return false;
    } catch (e) {
      print('⚠️ Error inesperado en registro: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('${Env.baseUrl}/login?email=$email&password=$password');

    try {
      final response = await http.post(
        url,
        headers: {'accept': 'application/json'}, // según lo que acepta el backend
      );

      print('🔵 Login request: POST $url');
      print('🔴 Status code: ${response.statusCode}');
      print('⚪ Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded;
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error en login: $e');
      return null;
    }
  }

  Future<bool> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('${Env.baseUrl}/changePassword');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('🔒 Error al cambiar contraseña: ${response.body}');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nombres');
  }

  Future<String?> getUserDni() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('dni');
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }
}