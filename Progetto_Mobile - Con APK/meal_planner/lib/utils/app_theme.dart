import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF4CAF50);
  static const Color secondary = Color(0xFFFF7043);
  static const Color accent = Color(0xFFFFC107);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          secondary: secondary,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: surface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: const Color(0xFFF8F8F8),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: Color(0xFFE8F5E9),
          labelStyle: TextStyle(color: primary),
        ),
      );
}

class AppRoutes {
  static const String home = '/';
  static const String recipeList = '/recipes';
  static const String recipeDetail = '/recipes/detail';
  static const String recipeForm = '/recipes/form';
  static const String pantry = '/pantry';
  static const String pantryForm = '/pantry/form';
  static const String expiryManagement = '/pantry/expiry';
  static const String mealPlan = '/meal-plan';
  static const String mealForm = '/meal-plan/form';
  static const String shopping = '/shopping';
  static const String shoppingForm = '/shopping/form';
  static const String stats = '/stats';
  static const String suggestions = '/suggestions';
}
