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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _termsAccepted = false;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onContinuar() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final usuario = _emailController.text.trim();
    final password = _passwordController.text;

    if (usuario.isEmpty) {
      setState(() => _emailError = 'Ingresa tu usuario');
      return;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Ingresa tu contraseña');
      return;
    }

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos')),
      );
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
        );
      } else {
        setState(() {
          _emailError = 'Usuario o contraseña incorrectos';
          _passwordError = 'Usuario o contraseña incorrectos';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _passwordError = 'Usuario o contraseña incorrectos';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Color(0xCC000000),
                    Color(0xE6101622),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        'KAPTUR',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(letterSpacing: 10),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'INICIAR SESIÓN',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(letterSpacing: 4),
                      ),
                      const SizedBox(height: 48),
                      _buildInput(
                        controller: _emailController,
                        hint: 'Usuario',
                        icon: Icons.person_outline,
                        errorText: _emailError,
                      ),
                      const SizedBox(height: 14),
                      _buildInput(
                        controller: _passwordController,
                        hint: 'Contraseña',
                        icon: Icons.lock_outline,
                        errorText: _passwordError,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTermsRow(),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _onContinuar,
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('CONTINUAR'),
                      ),
                      const SizedBox(height: 40),
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_passwordVisible,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 18),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textHint,
                  size: 18,
                ),
                onPressed: () {
                  setState(() => _passwordVisible = !_passwordVisible);
                },
              )
            : null,
        errorText: errorText,
        errorStyle: const TextStyle(color: AppColors.danger, fontSize: 10),
      ),
    );
  }

  Widget _buildTermsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _termsAccepted,
          activeColor: AppColors.orange,
          onChanged: (v) => setState(() => _termsAccepted = v ?? false),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                children: [
                  TextSpan(text: 'Aceptas las '),
                  TextSpan(
                    text: 'condiciones de uso',
                    style: TextStyle(color: AppColors.orange),
                  ),
                  TextSpan(text: ' y el '),
                  TextSpan(
                    text: 'aviso de privacidad',
                    style: TextStyle(color: AppColors.orange),
                  ),
                  TextSpan(text: ' de Kaptur.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
