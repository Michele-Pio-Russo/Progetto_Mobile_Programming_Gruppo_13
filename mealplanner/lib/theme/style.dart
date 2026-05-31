import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  static const Color coloreSfondo = Color(0xFFFAF9F6); // Bianco sporco/Panna chiaro
  static const Color colorePrimario = Color(0xFF7CA982); // Verde Salvia
  static const Color coloreTestoPrincipale = Color(0xFF2C302E); // Grigio Antracite
  static const Color coloreTestoSecondario = Color(0xFF8B928E); // Grigio medio per i dettagli
  static const Color coloreBianco = Colors.white; // Per le Card
  static const Color coloreErrore = Color(0xFFE57373); // Rosso morbido per eliminare

  static const double raggioCard = 24.0;
  static const double raggioBottoni = 20.0;
  static const EdgeInsets paddingGlobale = EdgeInsets.all(16.0);

  static List<BoxShadow> ombraNuvola = [
    BoxShadow(
      color: coloreTestoPrincipale.withValues(alpha: 0.04), // 4% di opacità, leggerissima
      blurRadius: 24, // Molto diffusa
      spreadRadius: 0,
      offset: const Offset(0, 8), // Leggermente verso il basso
    ),
  ];

  static ThemeData get temaApp {
    return ThemeData(
      scaffoldBackgroundColor: coloreSfondo,
      primaryColor: colorePrimario,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF7CA982),
        onPrimary: Color(0xFFFFFFFF),
        surface: coloreSfondo,
        onSurface: coloreTestoPrincipale,
        error: coloreErrore,
      ),
      
      // Font Nunito applicato ovunque in automatico
      textTheme: GoogleFonts.nunitoTextTheme().apply(
        bodyColor: coloreTestoPrincipale,
        displayColor: coloreTestoPrincipale,
      ),

      // Stile della Barra Superiore
      appBarTheme: AppBarTheme(
        backgroundColor: coloreSfondo,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: coloreTestoPrincipale),
        titleTextStyle: GoogleFonts.nunito(
          color: coloreTestoPrincipale,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Stile Bottoni Principali
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorePrimario,
          foregroundColor: coloreBianco,
          elevation: 0, // Niente ombra predefinita per non sporcare il design
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(raggioBottoni),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Stile Bottoni Secondari
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: coloreTestoPrincipale,
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(raggioBottoni),
          ),
        ),
      ),

      // Stile Card globale
      cardTheme: CardThemeData(
        color: coloreBianco,
        elevation: 0, // Togliamo l'ombra di default di Flutter
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raggioCard),
        ),
        // I margini verranno gestiti nelle singole view
      ),
    );
  }
}