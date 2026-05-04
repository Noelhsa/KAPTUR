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

  Future<List<dynamic>> obtenerRoles() async {
    final response = await _dio.get('/roles');
    return response.data;
  }

  Future<Map<String, dynamic>> login({
    required String usuario,
    required String contrasena,
  }) async {
    final response = await _dio.post(
      '/login',
      data: {
        'usuario': usuario,
        'contrasena': contrasena,
      },
    );

    return response.data;
  }
}
