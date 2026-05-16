import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/presentacion/screens/auth/pantalla_login.dart';

void main() {
  runApp(const ProviderScope(child: KapturApp()));
}

class KapturApp extends StatelessWidget {
  const KapturApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KAPTUR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
