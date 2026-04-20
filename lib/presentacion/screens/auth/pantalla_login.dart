import 'package:flutter/material.dart';
import '../../../config/themes/tema_app.dart';
import '../pantalla_principal.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _termsAccepted   = false;

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
      _emailError    = null;
      _passwordError = null;
    });

    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Ingresa un correo válido');
      return;
    }
    if (password.length < 6) {
      setState(() => _passwordError = 'Mínimo 6 caracteres');
      return;
    }
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInput(
                    controller:   _emailController,
                    hint:         'Correo electrónico',
                    icon:         Icons.email_outlined,
                    errorText:    _emailError,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _buildInput(
                    controller: _passwordController,
                    hint:       'Contraseña',
                    icon:       Icons.lock_outline,
                    errorText:  _passwordError,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTermsRow(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _onContinuar,
                    child: const Text('CONTINUAR'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [AppColors.navy, AppColors.background],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text(
            'KAPTUR',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              letterSpacing: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'INICIAR SESIÓN',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              letterSpacing: 4,
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
      controller:   controller,
      obscureText:  isPassword && !_passwordVisible,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      decoration: InputDecoration(
        hintText:  hint,
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
        errorText:  errorText,
        errorStyle: const TextStyle(color: AppColors.danger, fontSize: 10),
      ),
    );
  }

  Widget _buildTermsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value:       _termsAccepted,
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