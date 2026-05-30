import 'package:flutter/material.dart';
import '../models/ricette_model.dart';
import '../servizi/salvataggio_ricette.dart';

class RicetteViewModel extends ChangeNotifier {
  // Lista privata di tutte le ricette nel ricettacolo
  final List<Ricette> _ricette = [];

  // Istanza del servizio per salvare/caricare da SharedPreferences
  final ServizioPreferenzeRicette _servizio = ServizioPreferenzeRicette();

  // Getter per consentire alla View di leggere la lista di ricette
  List<Ricette> get ricette => _ricette;

  // Costruttore: carica i dati salvati all'avvio dell'applicazione
  RicetteViewModel() {
    _inizializzaDati();
  }

  // Lista di ricette predefinite per popolare l'app al primo avvio
  static final List<Ricette> _ricettePredefinite = [
    Ricette(
      id: '1',
      titolo: 'Spaghetti alla Carbonara',
      preparazione: 'Un classico della cucina romana preparato con guanciale croccante, tuorli d\'uovo freschi, pecorino romano e abbondante pepe nero.',
      ingredienti: ['Spaghetti', 'Guanciale', 'Tuorli d\'uovo', 'Pecorino Romano', 'Pepe nero'],
      categoria: 'Primo Piatto',
    ),
    Ricette(
      id: '2',
      titolo: 'Insalata Caesar',
      preparazione: 'Un\'insalata fresca e saporita con pollo grigliato, crostini croccanti, scaglie di parmigiano e la classica salsa Caesar.',
      ingredienti: ['Lattuga', 'Petto di pollo', 'Crostini di pane', 'Parmigiano Reggiano', 'Salsa Caesar'],
      categoria: 'Piatto Unico',
    ),
    Ricette(
      id: '3',
      titolo: 'Toast e Caffè',
      preparazione: 'Una colazione semplice e veloce, con toast caldo farcito con prosciutto e formaggio filante, accompagnato da un buon caffè.',
      ingredienti: ['Pane in cassetta', 'Prosciutto cotto', 'Formaggio a fette', 'Caffè'],
      categoria: 'Colazione',
    ),
    Ricette(
      id: '4',
      titolo: 'Burger di Manzo',
      preparazione: 'Gustoso burger di manzo servito in pane morbido con formaggio cheddar fuso, lattuga fresca, pomodoro e salse a scelta.',
      ingredienti: ['Pane da hamburger', 'Svizzera di manzo', 'Lattuga', 'Pomodoro', 'Formaggio Cheddar', 'Ketchup', 'Maionese'],
      categoria: 'Secondo Piatto',
    ),
    Ricette(
      id: '5',
      titolo: 'Zuppa di Lenticchie',
      preparazione: 'Una zuppa calda e nutriente preparata con lenticchie secche, un soffritto classico di verdure e brodo vegetale.',
      ingredienti: ['Lenticchie', 'Carote', 'Sedano', 'Cipolla', 'Brodo vegetale', 'Olio extravergine d\'oliva'],
      categoria: 'Piatto Unico',
    ),
    Ricette(
      id: '6',
      titolo: 'Yogurt con Frutta',
      preparazione: 'Uno spuntino sano e fresco a base di yogurt greco cremoso, dolcificato con miele e guarnito con frutta fresca e granola.',
      ingredienti: ['Yogurt greco', 'Miele', 'Fragole', 'Mirtilli', 'Granola'],
      categoria: 'Spuntino',
    ),
    Ricette(
      id: '7',
      titolo: 'Frutta Secca',
      preparazione: 'Un mix energetico e nutriente di frutta secca a guscio, ideale per una ricarica rapida durante la giornata.',
      ingredienti: ['Mandorle', 'Noci', 'Nocciole', 'Anacardi'],
      categoria: 'Spuntino',
    ),
    Ricette(
      id: '8',
      titolo: 'Torta al Cioccolato',
      preparazione: 'Una torta soffice e golosa ricca di cioccolato, perfetta per la colazione, la merenda o come dessert di fine pasto.',
      ingredienti: ['Farina', 'Zucchero', 'Cacao amaro', 'Burro', 'Uova', 'Lievito per dolci'],
      categoria: 'Dolce',
    ),
    Ricette(
      id: '9',
      titolo: 'Gelato alla Vaniglia',
      preparazione: 'Un dessert classico e rinfrescante con gelato cremoso alla vaniglia, eventualmente guarnito con topping a scelta.',
      ingredienti: ['Gelato alla vaniglia', 'Cialda', 'Topping al cioccolato', 'Granella di nocciole'],
      categoria: 'Dolce',
    ),
  ];

  // Inizializza i dati caricandoli dalla memoria locale.
  // Se la memoria è vuota (primo avvio), carica le ricette predefinite e le salva.
  Future<void> _inizializzaDati() async {
    final datiSalvati = await _servizio.caricaRicette();
    _ricette.clear();
    
    if (datiSalvati.isEmpty) {
      _ricette.addAll(_ricettePredefinite);
      await _salvaSuDisco();
    } else {
      _ricette.addAll(datiSalvati);
    }
    
    notifyListeners();
  }

  // Metodo privato per salvare la lista corrente su SharedPreferences
  Future<void> _salvaSuDisco() async {
    await _servizio.salvaRicette(_ricette);
  }

  // Aggiunge una nuova ricetta al ricettacolo
  void aggiungiRicetta(Ricette nuovaRicetta) {
    _ricette.add(nuovaRicetta);
    _salvaSuDisco();
    notifyListeners();
  }

  // Rimuove una ricetta in base all'ID
  void rimuoviRicetta(String id) {
    _ricette.removeWhere((ricetta) => ricetta.id == id);
    _salvaSuDisco();
    notifyListeners();
  }

  // Modifica una ricetta esistente sostituendola
  void modificaRicettaCompleta(Ricette ricettaModificata) {
    final indice = _ricette.indexWhere((r) => r.id == ricettaModificata.id);
    if (indice != -1) {
      _ricette[indice] = ricettaModificata;
      _salvaSuDisco();
      notifyListeners();
    }
  }

  // Restituisce una singola ricetta dato il suo ID (molto utile per accoppiamenti)
  Ricette? ottieniRicettaPerId(String id) {
    try {
      return _ricette.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // Filtra le ricette in base alla categoria
  List<Ricette> filtraPerCategoria(String categoria) {
    if (categoria == 'Tutte' || categoria.isEmpty) {
      return _ricette;
    }
    return _ricette.where((r) => r.categoria == categoria).toList();
  }

  // Cerca ricette tramite una parola chiave (ricerca nel titolo, nella preparazione o negli ingredienti)
  List<Ricette> cercaRicette(String query) {
    if (query.isEmpty) {
      return _ricette;
    }
    final q = query.toLowerCase();
    return _ricette.where((r) =>
        r.titolo.toLowerCase().contains(q) ||
        r.preparazione.toLowerCase().contains(q) ||
        r.ingredienti.any((ing) => ing.toLowerCase().contains(q))
    ).toList();
  }
}
