import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.kaptur.online/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  String _mensajeError(DioException e, String mensajeDefault) {
    final data = e.response?.data;

    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }

    if (data is Map && data['mensaje'] != null) {
      return data['mensaje'].toString();
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Tiempo de espera agotado. Revisa tu conexión.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Error de conexión con el servidor.';
    }

    return mensajeDefault;
  }

  Future<Map<String, dynamic>> obtenerInicioSupervisor(int idSupervisor) async {
    try {
      final response = await _dio.get('/supervisor/inicio/$idSupervisor');

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _mensajeError(e, 'Error al obtener el resumen del supervisor'),
      );
    } catch (_) {
      throw Exception('Error inesperado al obtener el resumen del supervisor');
    }
  }

  // ── Login ────────────────────────────────────────────────

  Future<Map<String, dynamic>> login({
    required String usuario,
    required String contrasena,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'usuario': usuario,
          'contrasena': contrasena,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Usuario o contraseña incorrectos');
      }

      throw Exception(
        _mensajeError(e, 'Error conectando con el servidor'),
      );
    } catch (_) {
      throw Exception('Error inesperado al iniciar sesión');
    }
  }

  // ── Roles ────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> obtenerRoles() async {
    try {
      final response = await _dio.get('/roles');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _mensajeError(e, 'Error al obtener roles'),
      );
    } catch (_) {
      throw Exception('Error inesperado al obtener roles');
    }
  }

  // ── Catálogos básicos ────────────────────────────────────

  Future<List<Map<String, dynamic>>> obtenerInstalaciones() async {
    try {
      final response = await _dio.get('/instalaciones');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _mensajeError(e, 'Error al obtener instalaciones'),
      );
    } catch (_) {
      throw Exception('Error inesperado al obtener instalaciones');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerTiposInstalacion() async {
    try {
      final response = await _dio.get('/tipos-instalacion');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _mensajeError(e, 'Error al obtener tipos de instalación'),
      );
    } catch (_) {
      throw Exception('Error inesperado al obtener tipos de instalación');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerPartesInstalacion(
    int idInstalacion,
  ) async {
    try {
      final response = await _dio.get('/partes-instalacion/$idInstalacion');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _mensajeError(e, 'Error al obtener partes de instalación'),
      );
    } catch (_) {
      throw Exception('Error inesperado al obtener partes de instalación');
    }
  }

  // ── Auditorías ───────────────────────────────────────────

  Future<Map<String, dynamic>> crearAuditoria({
    required int idInstalacion,
    required int idTipoInstalacion,
    int? idParteInstalacion,
    required int idSupervisor,
    required bool ptObtenido,
    required bool ptVigente,
    String? observacionesGenerales,
  }) async {
    try {
      final response = await _dio.post(
        '/auditorias',
        data: {
          'id_instalacion': idInstalacion,
          'id_tipo_instalacion': idTipoInstalacion,
          'id_parte_instalacion': idParteInstalacion,
          'id_supervisor': idSupervisor,
          'pt_obtenido': ptObtenido,
          'pt_vigente': ptVigente,
          'observaciones_generales': observacionesGenerales,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _mensajeError(e, 'Error al crear auditoría'),
      );
    } catch (_) {
      throw Exception('Error inesperado al crear auditoría');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerAuditorias() async {
    try {
      final response = await _dio.get('/auditorias');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _mensajeError(e, 'Error al obtener auditorías'),
      );
    } catch (_) {
      throw Exception('Error inesperado al obtener auditorías');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerAuditoriasJefe() async {
    try {
      final response = await _dio.get('/auditorias/jefe');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _mensajeError(e, 'Error al obtener auditorías del jefe'),
      );
    } catch (_) {
      throw Exception('Error inesperado al obtener auditorías del jefe');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerHistorialAuditoriasJefe(
    int idJefe,
  ) async {
    try {
      final response = await _dio.get('/auditorias/historial-jefe/$idJefe');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _mensajeError(e, 'Error al obtener el historial de auditorías'),
      );
    } catch (_) {
      throw Exception('Error inesperado al obtener el historial de auditorías');
    }
  }

  Future<Map<String, dynamic>> aprobarAuditoria({
    required int idAuditoria,
    required int idJefe,
    required bool aprobado,
    String? comentario,
  }) async {
    try {
      final response = await _dio.post(
        '/auditorias/$idAuditoria/aprobar',
        data: {
          'id_jefe': idJefe,
          'aprobado': aprobado,
          'comentario': comentario,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _mensajeError(e, 'Error al aprobar o rechazar auditoría'),
      );
    } catch (_) {
      throw Exception('Error inesperado al aprobar o rechazar auditoría');
    }
  }
}
