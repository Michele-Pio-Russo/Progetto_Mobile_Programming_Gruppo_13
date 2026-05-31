import 'package:flutter/material.dart';
import '../models/piano_pasti_model.dart';
import '../servizi/salvataggio_piano_pasti.dart';

class PianoPastiViewModel extends ChangeNotifier {

  // I pasti useranno ID basati sulla data reale per gestire infinite settimane
  final List<PianoPasti> _pasti = [];

  // Istanza del servizio per il salvataggio
  final ServizioPreferenzePianoPasti _servizio = ServizioPreferenzePianoPasti();

  // Costruttore
  PianoPastiViewModel() {
    _inizializzaDati();
  }

  // Metodo get usato dalla View per leggere i pasti
  List<PianoPasti> get pasti => _pasti;

  // Metodo get usato dalla view per ottenere il numero esatto di pasti pianificati
  int get numeroPastiPianificati =>
      _pasti.where((p) => p.idRicetta != '-').length;

  // Restituisce solo i pasti effettivamente pianificati per generare la spesa
  List<PianoPasti> get pastiEffettivi =>
      _pasti.where((p) => p.idRicetta != '-').toList();

  // Inizializza i dati caricandoli dalla memoria locale.
  Future<void> _inizializzaDati() async {
    final datiSalvati = await _servizio.caricaPasti();
    _pasti.clear();
    _pasti.addAll(datiSalvati);
    notifyListeners();
  }

  // Metodo privato per salvare la lista corrente su SharedPreferences
  Future<void> _salvaSuDisco() async {
    await _servizio.salvaPasti(_pasti);
  }

  // Funzione per i requisiti di aggiunta e modifica
  void salvaPasto(
    String id,
    String giorno,
    String tipologia,
    String nomeRicetta,
    String idRicetta,
  ) {
    // Cerca il pasto tramite l'id
    final index = _pasti.indexWhere((pasto) => pasto.id == id);

    // Se esiste, lo sovrascrive (caso di modifica)
    if (index != -1) {
      // indexWhere se non trova nulla restituisce -1
      _pasti[index] = PianoPasti(
        id: id,
        giorno: giorno,
        tipologia: tipologia,
        nomeRicetta: nomeRicetta,
        idRicetta: idRicetta,
      ); // Manteniamo l'idRicetta, così da non perdere il collegamento con la ricetta
      // Altrimenti, lo aggiunge al piano pasti (caso di aggiunta)
    } else {
      _pasti.add(
        PianoPasti(
          id: id,
          giorno: giorno,
          tipologia: tipologia,
          nomeRicetta: nomeRicetta,
          idRicetta: idRicetta,
        ),
      );
    }
    // Segnalazione alla View
    _salvaSuDisco();
    notifyListeners();
  }

  // Funzione per il requisito di rimozione
  void eliminaPasto(String id) {
    // Prendiamo l'indice del pasto da eliminare
    final index = _pasti.indexWhere((pasto) => pasto.id == id);
    if (index != -1) {
      // Se lo trova:
      _pasti[index] = PianoPasti(
        // Salviamo i dati del pasto, ma nomeRicetta è vuoto, così da non visualizzarlo più
        id: _pasti[index].id,
        giorno: _pasti[index].giorno,
        tipologia: _pasti[index].tipologia,
        nomeRicetta: '-', // La view leggerà solo questo
        idRicetta: '-', // Eliminiamo il collegamento con la ricetta
      );

      // Notifichiamo alla View la rimozione e salviamo su disco
      _salvaSuDisco();
      notifyListeners();
    }
  }

  // Rimuove i riferimenti a una ricetta eliminata dal ricettacolo
  void rimuoviRiferimentiRicetta(String idRicetta) {
    bool modificato =
        false; // Flag per capire se abbiamo fatto pulizia e dobbiamo avvisare la View
    for (int i = 0; i < _pasti.length; i++) {
      if (_pasti[i].idRicetta == idRicetta) {
        // Se troviamo un pasto con la ricetta cancellata
        _pasti[i] = PianoPasti(
          // Lo "resettiamo" mantenendo solo id, giorno e tipologia
          id: _pasti[i].id,
          giorno: _pasti[i].giorno,
          tipologia: _pasti[i].tipologia,
          nomeRicetta: '-',
          idRicetta: '-',
        );
        modificato = true;
      }
    }
    // Notifichiamo alla View se abbiamo modificato qualcosa
    if (modificato) {
      _salvaSuDisco();
      notifyListeners();
    }
  }
}