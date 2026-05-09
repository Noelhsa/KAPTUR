import 'package:dio/dio.dart';

class ApiService {
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

  Future<Map<String, dynamic>> login({
    required String usuario,
    required String contrasena,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'usuario': usuario, 'contrasena': contrasena},
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Timeout: el servidor no respondió en 10s (¿IP accesible desde esta red?)');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Sin conexión: no se pudo alcanzar ${_dio.options.baseUrl} — ¿el puerto está abierto?');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Usuario o contraseña incorrectos');
      }
      if (e.response?.statusCode == 500) {
        throw Exception(
            'Error interno del servidor (500): ${e.response?.data}');
      }
      throw Exception(
          'DioError ${e.type.name} — status: ${e.response?.statusCode} — ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerAuditoriasJefe() async {
    try {
      final response = await _dio.get('/auditorias/jefe');

      final data = response.data;

      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }

      throw Exception('Respuesta inválida del servidor');
    } on DioException catch (e) {
      print('ERROR obtenerAuditoriasJefe: ${e.message}');
      throw Exception('Error obteniendo auditorías del jefe');
    } catch (e) {
      print('ERROR inesperado obtenerAuditoriasJefe: $e');
      throw Exception('Error inesperado obteniendo auditorías');
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
      print('ERROR aprobarAuditoria: ${e.message}');
      throw Exception('Error aprobando auditoría');
    } catch (e) {
      print('ERROR inesperado aprobarAuditoria: $e');
      throw Exception('Error inesperado aprobando auditoría');
    }
  }
}
