import 'package:flutter/material.dart';

class AppTheme {
  // Cores da nossa Paleta (Minimalista: Branco, Cinza suave, botão Azul/Verde vibrante)
  static const Color primaryColor = Color(
    0xFF007AFF,
  ); // Azul vibrante estilo iOS/Moderno
  static const Color backgroundColor = Color(
    0xFFF8F9FA,
  ); // Cinza super claro/off-white
  static const Color textPrimaryColor = Color(0xFF1A1A1A);
  static const Color textSecondaryColor = Color(0xFF6C757D);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        background: backgroundColor,
        primary: primaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,

      // Tipografia global adaptativa
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textPrimaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        bodyLarge: TextStyle(color: textSecondaryColor, fontSize: 16),
      ),

      // Estilo global do nosso Botão Primário
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(
            double.infinity,
            56,
          ), // Largura 100% flexível, altura 56
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16,
            ), // Bordas arredondadas e modernas
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
