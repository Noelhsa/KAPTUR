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

      throw Exception('Error conectando con el servidor');
    } catch (e) {
      throw Exception('Error inesperado');
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
