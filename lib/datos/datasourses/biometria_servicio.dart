import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometriaServicio {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final LocalAuthentication _auth = LocalAuthentication();

  static const String _keyActivada = 'biometria_activada';
  static const String _keyUsuario = 'biometria_usuario';
  static const String _keyContrasena = 'biometria_contrasena';

  Future<bool> biometriaDisponible() async {
    try {
      final bool dispositivoSoporta = await _auth.isDeviceSupported();
      final bool puedeRevisarBiometria = await _auth.canCheckBiometrics;
      final biometricos = await _auth.getAvailableBiometrics();

      return dispositivoSoporta &&
          puedeRevisarBiometria &&
          biometricos.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> autenticar() async {
    try {
      final disponible = await biometriaDisponible();

      if (!disponible) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: 'Usa tu huella para iniciar sesión en KAPTUR',
        biometricOnly: true,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> guardarCredenciales({
    required String usuario,
    required String contrasena,
  }) async {
    await _storage.write(key: _keyActivada, value: 'true');
    await _storage.write(key: _keyUsuario, value: usuario);
    await _storage.write(key: _keyContrasena, value: contrasena);
  }

  Future<void> borrarCredenciales() async {
    await _storage.delete(key: _keyActivada);
    await _storage.delete(key: _keyUsuario);
    await _storage.delete(key: _keyContrasena);
  }

  Future<bool> biometriaActivada() async {
    final activada = await _storage.read(key: _keyActivada);
    final usuario = await _storage.read(key: _keyUsuario);
    final contrasena = await _storage.read(key: _keyContrasena);

    return activada == 'true' &&
        usuario != null &&
        usuario.isNotEmpty &&
        contrasena != null &&
        contrasena.isNotEmpty;
  }

  Future<Map<String, String>?> obtenerCredenciales() async {
    final usuario = await _storage.read(key: _keyUsuario);
    final contrasena = await _storage.read(key: _keyContrasena);

    if (usuario == null || contrasena == null) {
      return null;
    }

    return {
      'usuario': usuario,
      'contrasena': contrasena,
    };
  }
}
