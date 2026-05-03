import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
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

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onContinuar() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Usuario no encontrado');
      return;
    }
    if (password.length < 6) {
      setState(() => _passwordError = 'Contraseña incorrecta');
      return;
    }
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos')),
      );
      return;
    }

    // TODO: conectar con backend Node.js
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Imagen de fondo ───────────────────────────────
          // TODO: cambia la ruta en la línea de abajo por tu imagen
          // Ejemplo: 'recursos/imagenes/tu_imagen.jpg'
          // Línea 73 ↓
          Positioned.fill(
            child: Image.asset(
              'recursos/imagenes/foto_login.jpg', // <-- LÍNEA 75: cambia aquí
              fit: BoxFit.cover,
            ),
          ),

          // ── Gradiente oscuro sobre la imagen ─────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC000000), // negro 80% arriba
                    Color(0xE6101622), // background 90% abajo
                  ],
                ),
              ),
            ),
          ),

          // ── Contenido ─────────────────────────────────────
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

                      // Logo KAPTUR
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

                      // Campo correo
                      _buildInput(
                        controller: _emailController,
                        hint: 'Correo electrónico',
                        icon: Icons.email_outlined,
                        errorText: _emailError,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),

                      // Campo contraseña
                      _buildInput(
                        controller: _passwordController,
                        hint: 'Contraseña',
                        icon: Icons.lock_outline,
                        errorText: _passwordError,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),

                      // Checkbox términos
                      _buildTermsRow(),
                      const SizedBox(height: 28),

                      // Botón continuar
                      ElevatedButton(
                        onPressed: _onContinuar,
                        child: const Text('CONTINUAR'),
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
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
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
