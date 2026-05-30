import 'package:flutter/material.dart'; // Import flutter per changeNotifier
import '../models/lista_spesa_model.dart';

class ListaSpesaViewModel extends ChangeNotifier {
  final List<ListaSpesa> _prodotti = []; // Lista privata dei prodotti

  List<ListaSpesa> get prodotti => _prodotti; // Getter pubblico per accedere alla lista dei prodotti

  void aggiungiProdotto(String nome, String quantita) {
    final nuovoProdotto = ListaSpesa(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID univoco: millisecondi dall'epoca Unix convertiti in stringa
      nome: nome,
      quantita: quantita,
    );
    _prodotti.add(nuovoProdotto); // Aggiunge il prodotto alla lista
    notifyListeners(); // Avvisa la UI che i dati sono cambiati
  }

  void rimuoviProdotto(String id) {
    _prodotti.removeWhere((p) => p.id == id); // Rimuove il prodotto con quell'id
    notifyListeners(); // Avvisa la UI che i dati sono cambiati
  }

  void toggleComprato(String id) {
    final indice = _prodotti.indexWhere((p) => p.id == id); // Trova la posizione del prodotto con quell'id
    if (indice != -1) { // Se il prodotto esiste (indice diverso da -1)
      _prodotti[indice].comprato = !_prodotti[indice].comprato; // Cambia lo stato di comprato
      notifyListeners(); // Avvisa la UI che i dati sono cambiati
    }
  }
}