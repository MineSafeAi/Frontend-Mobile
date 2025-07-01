import 'dart:convert';
import 'dart:io';
import 'package:emergentes/models/report_acta_model.dart';
import 'package:emergentes/models/report_photo_model.dart';
import 'package:http/http.dart' as http;
import '../enviroments/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emergentes/models/condition_type_model.dart';
import 'package:emergentes/services/auth_service.dart';

import '../models/measure_corrective_model.dart';

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
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? [];
      return dataList.map((item) => ConditionType.fromJson(item)).toList();
    } else {
      throw Exception('No se pudo cargar los tipos de condición');
    }
  }

  Future<ReportActa?> obtenerReportePorId(int id) async {
    final url = Uri.parse('${Env.baseUrl}/api/ReporteActa/$id');
    final token = await AuthService().getToken();

    final response = await http.get(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print("📄 Obtener Reporte por ID - Status: ${response.statusCode}");
    print("📄 Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'];
      if (dataList.isNotEmpty) {
        return ReportActa.fromJson(dataList[0]);
      }
    }

    return null;
  }
  Future<List<ReportActa>> obtenerReportesConFotos() async {
    // Traemos la lista básica
    final url = Uri.parse('${Env.baseUrl}/api/ReporteActa');
    final token = await AuthService().getToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? [];

      // Convertir cada reporte básico
      final basicReports = dataList.map((e) => ReportActa.fromJson(e)).toList();

      // Ahora traer detalle con fotos para cada uno
      List<ReportActa> fullReports = [];
      for (final report in basicReports) {
        final detail = await obtenerReportePorId(report.id);
        if (detail != null) {
          fullReports.add(detail);
        }
      }
      return fullReports;
    } else {
      throw Exception('Error al cargar reportes: ${response.body}');
    }
  }

  Future<bool> enviarReporteActa({
    required String observaciones,
    required List<Map<String, dynamic>> fotos,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final usuarioId = await AuthService().getUserId();

    if (usuarioId == null) {
      print('❌ UsuarioId no encontrado');
      return false;
    }

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
      "usuarioId": usuarioId, // ✅ usamos el id dinámico
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
  Future<List<CorrectiveMeasure>> obtenerMedidasCorrectivas() async {
    final url = Uri.parse('${Env.baseUrl}/api/MedidaCorrectiva');
    final token = await AuthService().getToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? [];
      return dataList.map((e) => CorrectiveMeasure.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar medidas correctivas: ${response.body}');
    }
  }
  Future<CorrectiveMeasure?> obtenerMedidaPorReporte(int reporteActaId) async {
    final url = Uri.parse('${Env.baseUrl}/api/MedidaCorrectiva');
    final token = await AuthService().getToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List data = jsonResponse['data'];

      final medida = data.firstWhere(
            (m) => m['reporteActaId'] == reporteActaId,
        orElse: () => null,
      );

      if (medida != null) {
        return CorrectiveMeasure.fromJson(medida);
      }
    }

    return null;
  }
  Future<bool> actualizarMedidaCorrectiva(CorrectiveMeasure medida) async {
    final url = Uri.parse('${Env.baseUrl}/api/MedidaCorrectiva/update');
    final token = await AuthService().getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(medida.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> crearMedidaCorrectiva({
    required int reporteActaId,
    required String contenido,
    required String origen,
  }) async {
    final url = Uri.parse('${Env.baseUrl}/api/MedidaCorrectiva');
    final token = await AuthService().getToken();

    final body = {
      "reporteActaId": reporteActaId,
      "contenido": contenido,
      "origen": origen,
      "fechaGeneracion": DateTime.now().toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}