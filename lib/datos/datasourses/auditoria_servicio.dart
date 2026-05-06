import 'package:dio/dio.dart';
import 'package:proyecto_kaptur/datos/models/auditoria_modelo.dart';

class AuditoriaServicio {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.kaptur.online/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<List<Map<String, dynamic>>> obtenerInstalaciones() async {
    final response = await _dio.get('/instalaciones');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> obtenerTiposInstalacion() async {
    final response = await _dio.get('/tipos-instalacion');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> obtenerPartesInstalacion(
    int idInstalacion,
  ) async {
    final response = await _dio.get('/partes-instalacion/$idInstalacion');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> crearAuditoria(
    AuditoriaModelo auditoria,
  ) async {
    try {
      final response = await _dio.post(
        '/auditorias',
        data: auditoria.toJson(),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data.toString() ?? 'Error al crear la auditoría',
      );
    }
  }
}
