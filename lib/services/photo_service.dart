import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../enviroments/env.dart';
import 'package:http_parser/http_parser.dart';
import 'package:emergentes/models/condition_type_model.dart';

class PhotoService {
  Future<bool> enviarFotoCondicion({
    required int tipoCondicionId,
    required String ruta,
    required String nivelRiesgo,
    required String descripcion,
    required DateTime fechaCaptura,
    required File imagenFile,
  }) async {
    final uri = Uri.parse('${Env.baseUrl}/api/fotocondicion');
    final request = http.MultipartRequest('POST', uri);

    request.fields['tipoCondicionId'] = tipoCondicionId.toString();
    request.fields['ruta'] = ruta;
    request.fields['nivelRiesgo'] = nivelRiesgo;
    request.fields['descripcion'] = descripcion;
    request.fields['fechaCaptura'] = fechaCaptura.toIso8601String();

    final imageBytes = await imagenFile.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'imagen',
      imageBytes,
      filename: ruta,
      contentType: MediaType('image', 'jpeg'),
    ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Error al enviar: ${response.body}");
      return false;
    }
  }

  Future<int?> crearTipoCondicion(String nombre) async {
    final url = Uri.parse('${Env.baseUrl}/api/tipocondicion');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nombre': nombre}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id']; // asegúrate que el backend devuelve el ID
    } else {
      print('Error al crear tipoCondicion: ${response.body}');
      return null;
    }
  }

  Future<List<ConditionType>> obtenerTipoCondiciones() async {
    final url = Uri.parse('${Env.baseUrl}/api/TipoCondicion');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ConditionType.fromJson(item)).toList();
    } else {
      throw Exception('No se pudo cargar los tipos de condición');
    }
  }
}