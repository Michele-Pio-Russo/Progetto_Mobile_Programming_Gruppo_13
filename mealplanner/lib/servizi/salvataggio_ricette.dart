import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ricette_model.dart';

class ServizioPreferenzeRicette {
  // Chiave del contenitore per le ricette
  static const String _chiaveRicette = 'dati_ricette';

  // Salva la lista delle ricette in formato JSON sulle SharedPreferences
  Future<void> salvaRicette(List<Ricette> ricette) async {
    final preferenze = await SharedPreferences.getInstance();
    
    // Converte la lista di oggetti Ricette in una stringa JSON
    final stringaJson = jsonEncode(ricette.map((r) => r.aJson()).toList());
    
    // Salva la stringa
    await preferenze.setString(_chiaveRicette, stringaJson);
  }

  // Carica la lista delle ricette dalle SharedPreferences
  Future<List<Ricette>> caricaRicette() async {
    final preferenze = await SharedPreferences.getInstance();
    final stringaJson = preferenze.getString(_chiaveRicette);

    // Se non ci sono dati salvati, ritorna una lista vuota
    if (stringaJson == null) {
      return [];
    }

    // Altrimenti decodifica la stringa JSON e ricrea gli oggetti Ricette
    final List<dynamic> listaDecodificata = jsonDecode(stringaJson);
    return listaDecodificata.map((elementoJson) => Ricette.daJson(elementoJson)).toList();
  }
}
