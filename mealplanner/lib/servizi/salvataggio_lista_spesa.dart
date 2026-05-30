import 'dart:convert'; // Per convertire gli oggetti in stringa e viceversa
import 'package:shared_preferences/shared_preferences.dart'; // Per salvare i dati localmente sulla memoria del telefono
import '../models/lista_spesa_model.dart';

class ServizioPreferenzeListaSpesa {
  // Il nome del contenitore dove si salvano i dati
  static const String _chiaveSpesa = 'dati_lista_spesa';

  // Trasforma la lista di oggetti in stringa e la salva sul telefono
  Future<void> salvaArticoli(List<ListaSpesa> articoli) async {
    // Prendiamo le preferenze locali del telefono
    final preferenze = await SharedPreferences.getInstance();
    // Converte la lista di oggetti in una stringa JSON
    final stringaJson = jsonEncode(articoli.map((a) => a.aJson()).toList());
    await preferenze.setString(
      _chiaveSpesa,
      stringaJson,
    ); // Salva in locale la stringa
  }

  // Carica la stringa salvata in locale, la decodifica e la trasforma in una lista di oggetti ListaSpesa
  Future<List<ListaSpesa>> caricaArticoli() async {
    // Prendiamo le preferenze locali del telefono
    final preferenze = await SharedPreferences.getInstance();
    // Prende la stringa salvata in locale
    final stringaJson = preferenze.getString(_chiaveSpesa);

    if (stringaJson == null) {
      // Se non c'è nulla, restituisce una lista vuota
      return [];
    }

    // Se c'è una stringa, la decodifica in una lista di oggetti ListaSpesa
    final List<dynamic> listaDecodificata = jsonDecode(stringaJson);
    //Ritorna la lista di oggetti ListaSpesa decodificati
    return listaDecodificata
        .map((elementoJson) => ListaSpesa.daJson(elementoJson))
        .toList();
  }
}
