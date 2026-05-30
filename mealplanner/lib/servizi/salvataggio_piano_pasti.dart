import 'dart:convert'; // Per convertire gli oggetti in stringa e viceversa
import 'package:shared_preferences/shared_preferences.dart'; // Per salvare i dati localmente sulla memoria del telefono
import '../models/piano_pasti_model.dart';

class ServizioPreferenzePianoPasti {
  // Il nome del contenitore dove si salvano i dati
  static const String _chiavePasti = 'dati_piano_pasti';

  // Trasforma la lista di oggetti in stringa e la salva sul telefono
  Future<void> salvaPasti(List<PianoPasti> pasti) async {
    // Prendiamo le preferenze locali del telefono
    final preferenze = await SharedPreferences.getInstance();
    // Converte la lista di oggetti in una stringa JSON
    final stringaJson = jsonEncode(pasti.map((p) => p.aJson()).toList());
    await preferenze.setString(
      _chiavePasti,
      stringaJson,
    ); // Salva in locale la stringa
  }

  // Carica la stringa salvata in locale, la decodifica e la trasforma in una lista di oggetti PianoPasti
  Future<List<PianoPasti>> caricaPasti() async {
    // Prendiamo le preferenze locali del telefono
    final preferenze = await SharedPreferences.getInstance();
    // Prende la stringa salvata in locale
    final stringaJson = preferenze.getString(_chiavePasti);

    if (stringaJson == null) {
      // Se non c'è nulla, restituisce una lista vuota
      return [];
    }

    // Se c'è una stringa, la decodifica in una lista di oggetti PianoPasti
    final List<dynamic> listaDecodificata = jsonDecode(stringaJson);
    //Ritorna la lista di oggetti PianoPasti decodificati
    return listaDecodificata
        .map((elementoJson) => PianoPasti.daJson(elementoJson))
        .toList();
  }
}
