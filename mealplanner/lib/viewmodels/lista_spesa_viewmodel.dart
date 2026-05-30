import 'package:flutter/material.dart';
import '../models/lista_spesa_model.dart';

class ListaSpesaViewModel extends ChangeNotifier {
  final List<ListaSpesa> _prodotti = [];

  List<ListaSpesa> get prodotti => _prodotti;

  void aggiungiProdotto(String nome, String quantita) {
    final nuovoProdotto = ListaSpesa(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      quantita: quantita,
    );
    _prodotti.add(nuovoProdotto);
    notifyListeners();
  }

  void rimuoviProdotto(String id) {
    _prodotti.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void toggleComprato(String id) {
    final indice = _prodotti.indexWhere((p) => p.id == id);
    if (indice != -1) {
      _prodotti[indice].comprato = !_prodotti[indice].comprato;
      notifyListeners();
    }
  }

  void modificaProdotto(String id, String nuovoNome, String nuovaQuantita) {
    final indice = _prodotti.indexWhere((p) => p.id == id);
    if (indice != -1) {
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
    _prodotti.removeWhere((p) => p.comprato);
    notifyListeners();
  }
}