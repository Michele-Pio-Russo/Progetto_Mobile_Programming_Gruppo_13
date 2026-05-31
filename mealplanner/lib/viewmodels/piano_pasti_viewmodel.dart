import 'package:flutter/material.dart';
import '../models/piano_pasti_model.dart';

class PianoPastiViewModel extends ChangeNotifier {

  final List<PianoPasti> _pasti = [
    PianoPasti(
      id: 'lun_col',
      giorno: 'Lunedì',
      tipologia: 'Colazione',
      nomeRicetta: '-',
      idRicetta: '-',
    ), 
    PianoPasti(
      id: 'lun_pra',
      giorno: 'Lunedì',
      tipologia: 'Pranzo',
      nomeRicetta: 'Spaghetti alla Carbonara',
      idRicetta: '1',
    ),
    PianoPasti(
      id: 'lun_cen',
      giorno: 'Lunedì',
      tipologia: 'Cena',
      nomeRicetta: 'Insalata Caesar',
      idRicetta: '2',
    ),
    PianoPasti(
      id: 'lun_spu',
      giorno: 'Lunedì',
      tipologia: 'Spuntino',
      nomeRicetta: 'Yogurt con Frutta',
      idRicetta: '6',
    ),
    PianoPasti(
      id: 'lun_alt',
      giorno: 'Lunedì',
      tipologia: 'Altro',
      nomeRicetta: 'Torta al Cioccolato',
      idRicetta: '8',
    ),
    // Martedì
    PianoPasti(
      id: 'mar_col',
      giorno: 'Martedì',
      tipologia: 'Colazione',
      nomeRicetta: 'Toast e Caffè',
      idRicetta: '3',
    ),
    PianoPasti(
      id: 'mar_pra',
      giorno: 'Martedì',
      tipologia: 'Pranzo',
      nomeRicetta: 'Burger di Manzo',
      idRicetta: '4',
    ),
    PianoPasti(
      id: 'mar_cen',
      giorno: 'Martedì',
      tipologia: 'Cena',
      nomeRicetta: 'Zuppa di Lenticchie',
      idRicetta: '5',
    ),
    PianoPasti(
      id: 'mar_spu',
      giorno: 'Martedì',
      tipologia: 'Spuntino',
      nomeRicetta: 'Frutta Secca',
      idRicetta: '7',
    ),
    PianoPasti(
      id: 'mar_alt',
      giorno: 'Martedì',
      tipologia: 'Altro',
      nomeRicetta: 'Gelato alla Vaniglia',
      idRicetta: '9',
    ),
    PianoPasti(
      id: 'mer_col',
      giorno: 'Mercoledì',
      tipologia: 'Colazione',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'mer_pra',
      giorno: 'Mercoledì',
      tipologia: 'Pranzo',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'mer_cen',
      giorno: 'Mercoledì',
      tipologia: 'Cena',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'mer_spu',
      giorno: 'Mercoledì',
      tipologia: 'Spuntino',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'mer_alt',
      giorno: 'Mercoledì',
      tipologia: 'Altro',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    // Giovedì
    PianoPasti(
      id: 'gio_col',
      giorno: 'Giovedì',
      tipologia: 'Colazione',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'gio_pra',
      giorno: 'Giovedì',
      tipologia: 'Pranzo',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'gio_cen',
      giorno: 'Giovedì',
      tipologia: 'Cena',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'gio_spu',
      giorno: 'Giovedì',
      tipologia: 'Spuntino',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'gio_alt',
      giorno: 'Giovedì',
      tipologia: 'Altro',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'ven_col',
      giorno: 'Venerdì',
      tipologia: 'Colazione',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'ven_pra',
      giorno: 'Venerdì',
      tipologia: 'Pranzo',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'ven_cen',
      giorno: 'Venerdì',
      tipologia: 'Cena',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'ven_spu',
      giorno: 'Venerdì',
      tipologia: 'Spuntino',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'ven_alt',
      giorno: 'Venerdì',
      tipologia: 'Altro',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'sab_col',
      giorno: 'Sabato',
      tipologia: 'Colazione',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'sab_pra',
      giorno: 'Sabato',
      tipologia: 'Pranzo',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'sab_cen',
      giorno: 'Sabato',
      tipologia: 'Cena',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'sab_spu',
      giorno: 'Sabato',
      tipologia: 'Spuntino',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'sab_alt',
      giorno: 'Sabato',
      tipologia: 'Altro ',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'dom_col',
      giorno: 'Domenica',
      tipologia: 'Colazione',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'dom_pra',
      giorno: 'Domenica',
      tipologia: 'Pranzo',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'dom_cen',
      giorno: 'Domenica',
      tipologia: 'Cena',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'dom_spu',
      giorno: 'Domenica',
      tipologia: 'Spuntino',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
    PianoPasti(
      id: 'dom_alt',
      giorno: 'Domenica',
      tipologia: 'Altro',
      nomeRicetta: '-',
      idRicetta: '-',
    ),
  ];

  // Metodo get usato dalla View per leggere i pasti
  List<PianoPasti> get pasti => _pasti;

  // Metodo get usato dalla view per ottenere il numero esatto di pasti pianificati
  int get numeroPastiPianificati =>
      _pasti.where((p) => p.idRicetta != '-').length;

  // Restituisce solo i pasti effettivamente pianificati per generare la spesa
  List<PianoPasti> get pastiEffettivi =>
      _pasti.where((p) => p.idRicetta != '-').toList();

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

      // Notifichiamo alla View la rimozione
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
    if (modificato) notifyListeners();
  }
}
