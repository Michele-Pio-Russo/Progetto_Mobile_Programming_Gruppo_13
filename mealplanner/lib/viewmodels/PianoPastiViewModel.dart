import 'package:flutter/material.dart';
import '../models/PianoPasti.dart';

class PianoPastiViewModel extends ChangeNotifier{ // Con ChangeNotifier, possiamo avvisare la grafica quando i dati cambiano
  
  // Creiamo e riempiamo la lista che contiene i pasti pianificati (privata, perchè c'è il trattino basso)
  final List<PianoPasti> _pasti = [
    // Lunedì
    PianoPasti(id: '1', giorno: 'Lunedì 20 Maggio', tipologia: 'Colazione', nomeRicetta: '-'),
    PianoPasti(id: '2', giorno: 'Lunedì 20 Maggio', tipologia: 'Pranzo', nomeRicetta: 'Spaghetti alla Carbonara'),
    PianoPasti(id: '3', giorno: 'Lunedì 20 Maggio', tipologia: 'Cena', nomeRicetta: 'Insalata Caesar'),
    // Martedì
    PianoPasti(id: '4', giorno: 'Martedì 21 Maggio', tipologia: 'Colazione', nomeRicetta: 'Toast e Caffè'),
    PianoPasti(id: '5', giorno: 'Martedì 21 Maggio', tipologia: 'Pranzo', nomeRicetta: 'Burger di Manzo'),
    PianoPasti(id: '6', giorno: 'Martedì 21 Maggio', tipologia: 'Cena', nomeRicetta: 'Zuppa di Lenticchie'),
  ];

  //Metodo get usato dalla View per leggere i pasti
  List<PianoPasti> get pasti => _pasti;

  // Funzione per i requisiti di aggiunta e modifica
  void salvaPasto(String id, String giorno, String tipologia, String nomeRicetta) {
    // Cerca il pasto tramite l'id
    final index = _pasti.indexWhere((pasto) => pasto.id == id);

    // Se esiste, lo sovrascrive (caso di modifica)
    if (index != -1) { // indexWhere se non trova nulla restituisce -1
      _pasti[index] = PianoPasti(id: id, giorno: giorno, tipologia: tipologia, nomeRicetta: nomeRicetta);
    // Altrimenti, lo aggiunge al piano pasti (caso di aggiunta)
    } else {
      _pasti.add(PianoPasti(id: id, giorno: giorno, tipologia: tipologia, nomeRicetta: nomeRicetta));
    }
    // Segnalazione alla View
    notifyListeners();
  }

  // Funzione per il requisito di rimozione
  void eliminaPasto(String id) {
    // Prendiamo l'indice del pasto da eliminare
    final index = _pasti.indexWhere((pasto) => pasto.id == id);
    if (index != -1) { // Se lo trova:
      _pasti[index] = PianoPasti( // Salviamo i dati del pasto, ma nomeRicetta è vuoto, così da non visualizzarlo più
        id: _pasti[index].id,
        giorno: _pasti[index].giorno,
        tipologia: _pasti[index].tipologia,
        nomeRicetta: '-', // La view leggerà solo questo
      );

      // Notifichiamo alla View la rimozione
      notifyListeners();
    }
  }
}