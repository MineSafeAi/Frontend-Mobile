import 'dart:convert';
import 'dart:io';
import 'package:emergentes/models/report_acta_model.dart';
import 'package:emergentes/models/report_photo_model.dart';
import 'package:http/http.dart' as http;
import '../enviroments/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emergentes/models/condition_type_model.dart';
import 'package:emergentes/services/auth_service.dart';

class PhotoService {
  Future<List<ReportActa>> obtenerReportes() async {
    final url = Uri.parse('${Env.baseUrl}/api/ReporteActa');
    final token = await AuthService().getToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? [];
      return dataList.map((e) => ReportActa.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar reportes: ${response.body}');
    }
  }
  Future<List<ReportPhoto>> obtenerFotosPorReporte(int reporteActaId) async {
    final url = Uri.parse('${Env.baseUrl}/api/FotoCondicion/reporte/$reporteActaId');
    final token = await AuthService().getToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ReportPhoto.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar fotos: ${response.body}');
    }
  }

  Future<int?> crearTipoCondicion(String nombre) async {
    final url = Uri.parse('${Env.baseUrl}/api/tipocondicion');
    final token = await AuthService().getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nombre': nombre}),
    );

    print("Respuesta crearTipoCondicion: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return 1; // Retornar un valor dummy o indicativo de éxito
    } else {
      print('Error al crear tipoCondicion: ${response.body}');
      return null;
    }
  }

  Future<List<ConditionType>> obtenerTipoCondiciones() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${Env.baseUrl}/api/TipoCondicion');

    final response = await http.get(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ConditionType.fromJson(item)).toList();
    } else {
      throw Exception('No se pudo cargar los tipos de condición');
    }
  }

  Future<bool> enviarReporteActa({
    required int usuarioId,
    required String observaciones,
    required List<Map<String, dynamic>> fotos,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${Env.baseUrl}/api/ReporteActa');

    // Armar la lista de fotos correctamente
    final List<Map<String, dynamic>> fotosFinal = [];

    for (var foto in fotos) {
      final file = foto['file'] as File;
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      fotosFinal.add({
        "tipoCondicionId": foto['tipoCondicionId'],
        "ruta": null, // explícito
        "nivelRiesgo": foto['nivelRiesgo'],
        "descripcion": foto['descripcion'],
        "fechaCaptura": foto['fechaCaptura'] is DateTime
            ? (foto['fechaCaptura'] as DateTime).toIso8601String()
            : foto['fechaCaptura'],
        "imagen": base64Image,
      });
    }

    final payload = {
      "usuarioId": 1,
      "fechaCreacion": DateTime.now().toIso8601String(),
      "observaciones": observaciones,
      "fotos": fotosFinal,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    print('📤 Enviar ReporteActa - Status: ${response.statusCode}');
    print('📄 Body: ${response.body}');

    return response.statusCode == 200 || response.statusCode == 201;
  }
}