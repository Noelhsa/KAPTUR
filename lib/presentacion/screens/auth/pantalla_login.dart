import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/datos/datasourses/api_servicios.dart';
import 'package:proyecto_kaptur/presentacion/screens/pantalla_principal.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _rememberData = false;
  bool _isLoading = false;

  String? _usuarioError;
  String? _passwordError;

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onIniciarSesion() async {
    setState(() {
      _usuarioError = null;
      _passwordError = null;
    });

    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text;

    if (usuario.isEmpty) {
      setState(() => _usuarioError = 'Ingresa tu usuario');
      return;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Ingresa tu contraseña');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiService();

      final respuesta = await api.login(
        usuario: usuario,
        contrasena: password,
      );

      print('LOGIN RESPUESTA: $respuesta');

      if (!mounted) return;

      if (respuesta['success'] == true) {
        final usuarioLogueado = Map<String, dynamic>.from(respuesta['usuario']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PantallaPrincipal(usuario: usuarioLogueado),
          ),
        );
      } else {
        setState(() {
          _usuarioError = 'Usuario o contraseña incorrectos';
          _passwordError = 'Usuario o contraseña incorrectos';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _passwordError = 'Usuario o contraseña incorrectos';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          duration: const Duration(seconds: 5),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'recursos/imagenes/foto_login.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC050A12),
                    Color(0xEE101622),
                    Color(0xFA101622),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: altura - MediaQuery.of(context).padding.top,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      SizedBox(height: altura * 0.045),
                      Image.asset(
                        'recursos/imagenes/isotipo_kaptur.png',
                        height: 110,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 2),
                      Image.asset(
                        'recursos/imagenes/logotipo_kaptur.png',
                        height: 26,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'INICIA SESIÓN',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 4,
                        ),
                      ),
                      SizedBox(height: altura * 0.055),
                      _buildInput(
                        controller: _usuarioController,
                        hint: 'Usuario',
                        icon: Icons.person_outline,
                        errorText: _usuarioError,
                      ),
                      const SizedBox(height: 12),
                      _buildInput(
                        controller: _passwordController,
                        hint: 'Contraseña',
                        icon: Icons.lock_outline,
                        errorText: _passwordError,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberData,
                              activeColor: AppColors.orange,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.65),
                                width: 1.2,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _rememberData = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Recordar mis datos',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Contacta a tu administrador para recuperar el acceso',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: AppColors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onIniciarSesion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.orange.withOpacity(0.55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 23,
                                  height: 23,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.3,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Iniciar sesión',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 14),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 21,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.45,
                          ),
                          children: [
                            TextSpan(text: 'Al iniciar sesión, aceptas los '),
                            TextSpan(
                              text: 'Términos y Condiciones',
                              style: TextStyle(
                                color: AppColors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: ' y la '),
                            TextSpan(
                              text: 'Política de Privacidad',
                              style: TextStyle(
                                color: AppColors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: ' de KAPTUR.'),
                          ],
                        ),
                      ),
                      SizedBox(height: altura * 0.16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.textSecondary.withOpacity(0.85),
                            size: 17,
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'Tus datos están protegidos\ncon encriptación de extremo a extremo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? errorText,
    bool isPassword = false,
  }) {
    final bool hasError = errorText != null;

    return TextField(
      controller: controller,
      obscureText: isPassword && !_passwordVisible,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      cursorColor: AppColors.orange,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: hasError ? AppColors.danger : AppColors.textSecondary,
          size: 19,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 19,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              )
            : null,
        errorText: errorText,
        errorStyle: const TextStyle(
          color: AppColors.danger,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? AppColors.danger : Colors.white.withOpacity(0.28),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? AppColors.danger : AppColors.orange,
            width: 1.3,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.danger,
            width: 1.3,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.danger,
            width: 1.3,
          ),
        ),
      ),
    );
  }
}
