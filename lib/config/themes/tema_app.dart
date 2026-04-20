import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colores de KAPTUR ─────────────────────────────────────────
class AppColors {
  AppColors._(); // evita que se instancie

  static const Color navy       = Color(0xFF1F3A5F); // azul principal
  static const Color dark       = Color(0xFF212431); // fondo oscuro
  static const Color orange     = Color(0xFFEA5C1F); // acento naranja
  static const Color light      = Color(0xFFECEFF1); // fondo claro
  static const Color background = Color(0xFF101622); // fondo general
  static const Color surface    = Color(0xFF1A2035); // tarjetas

  // Estados
  static const Color success    = Color(0xFF22C55E); // verde - completado
  static const Color warning    = Color(0xFFF59E0B); // amarillo - pendiente
  static const Color danger     = Color(0xFFEF4444); // rojo - error/rechazo
  static const Color info       = Color(0xFF60A5FA); // azul - en progreso

  // Texto
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textHint      = Color(0xFF475569);
}

// ── Tema global de la app ─────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Paleta de colores
      colorScheme: const ColorScheme.dark(
        primary:   AppColors.orange,
        secondary: AppColors.navy,
        surface:   AppColors.surface,
        error:     AppColors.danger,
        onPrimary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),

      // Fondo general
      scaffoldBackgroundColor: AppColors.background,

      // Tipografía con Poppins
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.08,
        ),
        titleLarge: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        bodySmall: GoogleFonts.poppins(
          color: AppColors.textHint,
          fontSize: 11,
        ),
      ),

      // Estilo de botón principal (naranja)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.08,
          ),
        ),
      ),

      // Estilo de campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textHint,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.orange,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.danger,
          ),
        ),
      ),

      // AppBar sin sombra
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.06,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}