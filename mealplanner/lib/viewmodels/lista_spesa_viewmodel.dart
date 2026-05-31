import 'package:flutter/material.dart';
import '../models/lista_spesa_model.dart';

// Estende ChangeNotifier per poter notificare la UI quando i dati cambiano
class ListaSpesaViewModel extends ChangeNotifier {
  final List<ListaSpesa> _prodotti = [];

  List<ListaSpesa> get prodotti => _prodotti;

  void aggiungiProdotto(String nome, String quantita) {
    final nuovoProdotto = ListaSpesa(
      // Usiamo l'orario attuale in millisecondi come ID unico
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      quantita: quantita,
    );

    _prodotti.add(nuovoProdotto);

    notifyListeners();
  }

  void rimuoviProdotto(String id) {
    // Cerchiamo nella lista e rimuoviamo l'elemento che ha esattamente quell'ID
    _prodotti.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void toggleComprato(String id) {
    // Troviamo a quale indice (posizione) si trova il prodotto nella lista
    final indice = _prodotti.indexWhere((p) => p.id == id);

    // Se l'indice non è -1 significa che l'abbiamo trovato
    if (indice != -1) {
      // Invertiamo il suo stato
      _prodotti[indice].comprato = !_prodotti[indice].comprato;
      notifyListeners();
    }
  }

  void modificaProdotto(String id, String nuovoNome, String nuovaQuantita) {
    final indice = _prodotti.indexWhere((p) => p.id == id);

    if (indice != -1) {
      // Sostituiamo il vecchio oggetto con uno nuovo aggiornato, ma ci assicuriamo di mantenere il suo ID originale e lo stato 'comprato'.
      _prodotti[indice] = ListaSpesa(
        id: id,
        nome: nuovoNome,
        quantita: nuovaQuantita,
        comprato: _prodotti[indice].comprato,
      );
      notifyListeners();
    }
  }

  void rimuoviProdottiComprati() {
    _prodotti.removeWhere(
      (p) => p.comprato,
    ); // Elimina tutti quelli con comprato == true
    notifyListeners();
  }

  void generaDaPianoPasti(
    List<dynamic> pastiOggi,
    dynamic ricetteViewModel,
    List<dynamic> articoliDispensa,
  ) {
    // Scorriamo tutti i pasti previsti per oggi
    for (var pasto in pastiOggi) {
      // Controlliamo che il pasto abbia effettivamente una ricetta associata valida
      if (pasto.idRicetta != null &&
          pasto.idRicetta != '-' &&
          pasto.idRicetta.isNotEmpty) {
        // Andiamo a pescare i dettagli della ricetta tramite il suo ID
        final ricetta = ricetteViewModel.ottieniRicettaPerId(pasto.idRicetta);

        if (ricetta != null) {
          // Scorriamo tutti gli ingredienti necessari per questa ricetta
          for (var ing in ricetta.ingredienti) {
            // Controllo se questo ingrediente ce l'ho già in dispensa
            // Trim serve a eliminare eventuali spazi prima o dopo il nome e toLowerCase() per non avere problemi di maiuscole/minuscole
            bool inDispensa = articoliDispensa.any(
              (art) =>
                  art.nome.toLowerCase().trim() ==
                  ing.nome.toLowerCase().trim(),
            );
            // Controllo se l'ho già aggiunto alla lista della spesa in precedenza
            bool giaInLista = _prodotti.any(
              (p) =>
                  p.nome.toLowerCase().trim() == ing.nome.toLowerCase().trim(),
            );

            //Se non ce l'ho in dispensa e non è già nella lista lo aggiungo
            if (!inDispensa && !giaInLista) {
              // Uniamo quantità e unità di misura
              // Il dollar vuol dire che stiamo creando una stringa unica
              String q = "${ing.quantita} ${ing.unitaMisura}".trim();

              _prodotti.add(
                ListaSpesa(
                  // Creiamo un ID combinando l'orario e il nome
                  id: "${DateTime.now().millisecondsSinceEpoch}_${ing.nome}",
                  nome: ing.nome,
                  // Se la quantità è vuota, mettiamo un trattino di default
                  quantita: q.isEmpty ? '-' : q,
                ),
              );
            }
          }
        }
      }
    }
    // Avvisiamo l'interfaccia di aggiornarsi una sola volta alla fine.
    notifyListeners();
  }
}
