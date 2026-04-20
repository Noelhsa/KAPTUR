import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/themes/tema_app.dart';
import 'presentacion/screens/pantalla_principal.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KapturApp(),
    ),
  );
}

class KapturApp extends StatelessWidget {
  const KapturApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KAPTUR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const PantallaPrincipal(),
    );
  }
}