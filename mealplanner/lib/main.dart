import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< Updated upstream
import 'package:mealplanner/viewmodels/dispensa_viewmodel.dart';
import 'package:mealplanner/viewmodels/piano_pasti_viewmodel.dart';
import 'package:mealplanner/viewmodels/ricette_viewmodel.dart';
import 'package:mealplanner/views/navigazione_view.dart';
=======

import 'viewmodels/piano_pasti_viewmodel.dart';
import 'viewmodels/dispensa_viewmodel.dart';
import 'viewmodels/lista_spesa_viewmodel.dart';
import 'views/navigazione_view.dart';
>>>>>>> Stashed changes

void main() {
  // Assicura l'inizializzazione dei binding di Flutter (necessario per l'uso asincrono di SharedPreferences all'avvio)
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
<<<<<<< Updated upstream
        ChangeNotifierProvider(create: (context) => GestoreDispensa()), // Il provider per la gestione della dispensa
        ChangeNotifierProvider(create: (context) => PianoPastiViewModel()), // Il provider per la gestione del piano pasti
        ChangeNotifierProvider(create: (context) => RicetteViewModel()), // Il provider per la gestione del ricettacolo
=======
        ChangeNotifierProvider(create: (context) => GestoreDispensa()),
        ChangeNotifierProvider(create: (context) => PianoPastiViewModel()),
        ChangeNotifierProvider(create: (context) => ListaSpesaViewModel()),
>>>>>>> Stashed changes
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestione Dispensa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20, 
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const SchermataPrincipale(),
    );
  }
}