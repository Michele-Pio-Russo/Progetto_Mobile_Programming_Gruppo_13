import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dispensa_viewmodel.dart';
import '../views/navigazione_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GestoreDispensa(),
      child: const MiaAppDispensa(),
    ),
  );
}

class MiaAppDispensa extends StatelessWidget {
  const MiaAppDispensa({super.key});

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