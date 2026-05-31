import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/style.dart';
import 'viewmodels/dispensa_viewmodel.dart';
import 'viewmodels/piano_pasti_viewmodel.dart';
import 'viewmodels/lista_spesa_viewmodel.dart';
import 'viewmodels/ricette_viewmodel.dart';
import 'views/navigazione_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GestoreDispensa()),
        ChangeNotifierProvider(create: (context) => PianoPastiViewModel()),
        ChangeNotifierProvider(create: (context) => ListaSpesaViewModel()),
        ChangeNotifierProvider(create: (context) => RicetteViewModel()),
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
      theme: AppStyle.temaApp, 
      home: const SchermataPrincipale(),
    );
  }
}