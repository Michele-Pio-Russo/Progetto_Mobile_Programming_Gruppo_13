import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mealplanner/viewmodels/piano_pasti_viewmodel.dart';

class PianoPastiView extends StatelessWidget { // StatelessWidget perché non gestisce direttamente lo stato, ma si affida al ViewModel
  const PianoPastiView({super.key});

  // Metodo obbligatorio per costruire l'interfaccia utente del piano pasti
  @override
  Widget build(BuildContext context) {
    return Scaffold( // La struttura base di una pagina in flutter
      appBar: AppBar( // La barra superiore della pagina
        title: const Text('Piano pasti', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      // Ogni volta che il ViewModel cambia, il builder viene ricostruito con i nuovi dati
      body: Consumer<PianoPastiViewModel>( // Serve a verificare che il ViewModel stia cambiando
        /*
        Context : il contesto della pagina, lo passa flutter
        ViewModel : lo prende dal Provider
        Child : serve per ottimizzare le prestazioni, è opzionale e non lo usiamo in questo caso
         */
        builder: (context, viewModel, child) { // Il builder prende i dati dal ViewModel
          return Center( // Center prende il child e lo centra nella pagina
            child: Text(
              'Pasti pianificati: ${viewModel.numeroPastiPianificati}', // Mostra il numero di pasti pianificati tramite interpolazione
              style: const TextStyle(fontSize: 24),
            ),
          );

        },
      ),
    );
  }
}