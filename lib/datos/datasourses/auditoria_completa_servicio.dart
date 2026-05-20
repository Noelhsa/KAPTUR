import 'dart:io';
import 'package:dio/dio.dart';

class AuditoriaCompletaServicio {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.kaptur.online/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // ── Catálogos ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> obtenerInstalaciones() async {
    final r = await _dio.get('/instalaciones');
    return List<Map<String, dynamic>>.from(r.data);
  }

  Future<List<Map<String, dynamic>>> obtenerTiposInstalacion() async {
    final r = await _dio.get('/tipos-instalacion');
    return List<Map<String, dynamic>>.from(r.data);
  }

  Future<List<Map<String, dynamic>>> obtenerPartesInstalacion(
      int idInstalacion) async {
    final r = await _dio.get('/partes-instalacion/$idInstalacion');
    return List<Map<String, dynamic>>.from(r.data);
  }

  Future<List<Map<String, dynamic>>> obtenerTiposActo() async {
    final r = await _dio.get('/tipos-acto-inseguro');
    return List<Map<String, dynamic>>.from(r.data);
  }

  Future<List<Map<String, dynamic>>> obtenerOpcionesActo(int idTipoActo) async {
    final r = await _dio.get('/opciones-acto-inseguro/$idTipoActo');
    return List<Map<String, dynamic>>.from(r.data);
  }

  Future<List<Map<String, dynamic>>> obtenerCausas() async {
    final r = await _dio.get('/causas-acto-inseguro');
    return List<Map<String, dynamic>>.from(r.data);
  }

  // ── Subir archivo ─────────────────────────────────────────

  Future<String> subirEvidencia(File archivo) async {
    final formData = FormData.fromMap({
      'archivo': await MultipartFile.fromFile(
        archivo.path,
        filename: archivo.path.split('/').last,
      ),
    });

    final r = await Dio(BaseOptions(
      baseUrl: 'https://api.kaptur.online/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    )).post('/evidencias/subir', data: formData);

    if (r.data['success'] == true) {
      return r.data['ruta_archivo'] as String;
    }
    throw Exception('Error al subir el archivo');
  }

  // ── Guardar auditoría completa (BORRADOR) ─────────────────

  Future<Map<String, dynamic>> guardarAuditoriaCompleta({
    required int idInstalacion,
    required int idTipoInstalacion,
    int? idParteInstalacion,
    required int idSupervisor,
    required bool ptObtenido,
    required bool ptVigente,
    String? observacionesGenerales,
    required int totalPersonasObservadas,
    required int personasInternasTotal,
    required int personasExternasTotal,
    required List<Map<String, dynamic>> personas,
    required List<Map<String, dynamic>> actos,
    required List<Map<String, dynamic>> evidencias,
  }) async {
    try {
      final r = await _dio.post(
        '/auditorias/completa',
        data: {
          'id_instalacion': idInstalacion,
          'id_tipo_instalacion': idTipoInstalacion,
          'id_parte_instalacion': idParteInstalacion,
          'id_supervisor': idSupervisor,
          'pt_obtenido': ptObtenido,
          'pt_vigente': ptVigente,
          'observaciones_generales': observacionesGenerales,
          'total_personas_observadas': totalPersonasObservadas,
          'personas_internas_total': personasInternasTotal,
          'personas_externas_total': personasExternasTotal,
          'personas': personas,
          'actos': actos,
          'evidencias': evidencias,
        },
      );
      return Map<String, dynamic>.from(r.data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?.toString() ?? 'Error al guardar auditoría');
    }
  }

  // ── Obtener detalle (para pantalla de resumen) ────────────

  Future<Map<String, dynamic>> obtenerDetalle(int idAuditoria) async {
    try {
      final r = await _dio.get('/auditorias/$idAuditoria/detalle');
      return Map<String, dynamic>.from(r.data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?.toString() ?? 'Error al obtener detalle');
    }
  }

  // ── Confirmar → pasa a EN_REVISION ───────────────────────

  Future<void> confirmarAuditoria(int idAuditoria) async {
    try {
      await _dio.post('/auditorias/$idAuditoria/confirmar');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?.toString() ?? 'Error al confirmar auditoría');
    }
  }
}
