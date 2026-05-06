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
}
