import 'package:flutter/material.dart';
import '../models/dispensa_model.dart'; 

class GestoreDispensa extends ChangeNotifier {
  // La lista privata che contiene tutti gli articoli presenti in dispensa
  final List<Dispensa> _articoli = [];

  // Getter della lista
  List<Dispensa> get articoli => _articoli;

  // Metodo per caricare la lista
  void caricaArticoli(List<Dispensa> nuoviArticoli) {
    _articoli.clear();  // Evita i duplicati
    _articoli.addAll(nuoviArticoli);
    // Controlliamo lo stato critico di tutti gli articoli appena caricati
    for (var articolo in _articoli) {
      articolo.controllaStatoCritico();
    }
    notifyListeners();
  }

  // Metodo per aggiungere un nuovo articolo
  void aggiungiArticolo(Dispensa nuovoArticolo) {
    // Prima di inserirlo, ci assicuriamo che il suo stato critico sia aggiornato
    nuovoArticolo.controllaStatoCritico();
    _articoli.add(nuovoArticolo);
    
    notifyListeners();
  }

  // Metodo per rimuovere un articolo
  void rimuoviArticolo(String id) {
    _articoli.removeWhere((articolo) => articolo.id == id);
    notifyListeners();
  }

  // Metodo per aggiornare la quantità
  void aggiornaQuantita(String id, double nuovaQuantita) {
    final indice = _articoli.indexWhere((articolo) => articolo.id == id);
    
    if (indice != -1) {
      // Creiamo una copia dell'articolo modificando solo la quantità tramite il metodo copia di dispensa
      Dispensa articoloAggiornato = _articoli[indice].copia(quantita: nuovaQuantita);
      
      // Ricalcoliamo lo stato critico sulla copia appena creata
      articoloAggiornato.controllaStatoCritico();
      
      // Sostituiamo il vecchio oggetto con quello nuovo all'interno della lista
      _articoli[indice] = articoloAggiornato;
      
      notifyListeners();
    }
  }

  // Metodo per modificare un articolo
  void modificaArticoloCompleto(Dispensa articoloModificato) {
    final indice = _articoli.indexWhere((articolo) => articolo.id == articoloModificato.id);
    
    if (indice != -1) {
      articoloModificato.controllaStatoCritico();
      _articoli[indice] = articoloModificato;
      notifyListeners();
    }
  }

  // Getter per filtrare gli articoli in stato critico, serve per i badge di notifica
  List<Dispensa> get articoliCritici {
    return _articoli.where((articolo) => articolo.statoCritico).toList();
  }

  // Getter per filtrare gli articoli per categoria
  List<Dispensa> filtraPerCategoria(String categoria) {
    return _articoli.where((articolo) => articolo.categoria == categoria).toList();
  }
}