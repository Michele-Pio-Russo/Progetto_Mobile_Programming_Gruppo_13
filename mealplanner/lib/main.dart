import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/piano_pasti_viewmodel.dart';
import '../viewmodels/dispensa_viewmodel.dart';
import '../views/navigazione_view.dart';

void main() {
  runApp(
     MultiProvider( // Serve a caricare tutti i viewmodels dell'app
      providers: [
        ChangeNotifierProvider(create: (context) => GestoreDispensa()), // Il provider per la gestione della dispensa
        ChangeNotifierProvider(create: (context) => PianoPastiViewModel()), // Il provider per la gestione del piano pasti
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
      debugShowCheckedModeBanner: false, // Rimuove la scritta "Sotto esame/Debug" in alto a destra
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