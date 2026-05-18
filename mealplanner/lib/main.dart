import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Usiamo gli import di pacchetto esplicitando 'mealplanner'
import 'package:mealplanner/views/piano_pasti_view.dart';
import 'package:mealplanner/viewmodels/piano_pasti_viewmodel.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PianoPastiViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const PianoPastiView(),
    );
  }
}