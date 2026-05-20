import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dispensa_model.dart';

class ServizioPreferenze {
  // Il nome del contenitore dove si salvano i dati
  static const String _chiaveDispensa = 'dati_dispensa';

  // Trasforma la lista di oggetti in stringa e la salva sul telefono
  Future<void> salvaArticoli(List<Dispensa> articoli) async {
    final preferenze = await SharedPreferences.getInstance();
    
    // Trasforma ogni oggetto Dispensa in una mappa
    // Converte la lista in una stringa JSON
    final stringaJson = jsonEncode(articoli.map((a) => a.aJson()).toList());
    
    // Salva la stringa nel telefono
    await preferenze.setString(_chiaveDispensa, stringaJson);
  }

  // Legge la stringa dal telefono e la ritrasforma in lista di oggetti
  Future<List<Dispensa>> caricaArticoli() async {
    final preferenze = await SharedPreferences.getInstance();
    final stringaJson = preferenze.getString(_chiaveDispensa);

    // Se non c'è nulla salvato restituisce una lista vuota
    if (stringaJson == null) {
      return [];
    }

    // Se ci sono dati, decodifica la stringa JSON e ricostruisce gli oggetti Dispensa
    final List<dynamic> listaDecodificata = jsonDecode(stringaJson);
    return listaDecodificata.map((elementoJson) => Dispensa.daJson(elementoJson)).toList();
  }
}