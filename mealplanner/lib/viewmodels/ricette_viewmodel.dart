import 'package:flutter/material.dart';
import '../models/ricette_model.dart';
import '../servizi/salvataggio_ricette.dart';

// Classe responsabile per la logica di business e gestione dello stato delle ricette
// Usa ChangeNotifier per notificare la grafica (View) quando i dati cambiano
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
      ingredienti: [
        Ingrediente(nome: 'Spaghetti', quantita: '400', unitaMisura: 'g'),
        Ingrediente(nome: 'Guanciale', quantita: '150', unitaMisura: 'g'),
        Ingrediente(nome: 'Pecorino Romano', quantita: '100', unitaMisura: 'g'),
        Ingrediente(nome: 'Uova', quantita: '4', unitaMisura: 'pz'),
        Ingrediente(nome: 'Pepe nero', quantita: 'q.b.', unitaMisura: 'q.b.')
      ],
      categoria: 'Primi piatti',
      tempoPreparazione: '20', // Inserito numerico per agevolare i calcoli
      difficolta: 2,
      quantita: '4 persone',
      note: 'Usare uova a temperatura ambiente.',
      isPredefinita: true, // Indica che questa è una ricetta base dell'app
    ),
    Ricette(
      id: '2',
      titolo: 'Insalata Caesar',
      preparazione: 'Un\'insalata fresca e saporita con pollo grigliato, crostini croccanti, scaglie di parmigiano e la classica salsa Caesar.',
      ingredienti: [
        Ingrediente(nome: 'Lattuga', quantita: '1', unitaMisura: 'cespo'),
        Ingrediente(nome: 'Petto di pollo', quantita: '300', unitaMisura: 'g'),
        Ingrediente(nome: 'Crostini di pane', quantita: '50', unitaMisura: 'g'),
        Ingrediente(nome: 'Parmigiano Reggiano', quantita: '50', unitaMisura: 'g'),
        Ingrediente(nome: 'Salsa Caesar', quantita: '3', unitaMisura: 'cucchiai'),
      ],
      categoria: 'Piatto Unico',
      tempoPreparazione: '15',
      difficolta: 1,
      quantita: '2 porzioni',
      note: 'Aggiungere crostini all\'ultimo per non ammoridirli.',
      isPredefinita: true,
    ),
    Ricette(
      id: '3',
      titolo: 'Toast e Caffè',
      preparazione: 'Una colazione semplice e veloce, con toast caldo farcito con prosciutto e formaggio filante, accompagnato da un buon caffè.',
      ingredienti: [
        Ingrediente(nome: 'Pane in cassetta', quantita: '2', unitaMisura: 'fette'),
        Ingrediente(nome: 'Prosciutto cotto', quantita: '1', unitaMisura: 'fetta'),
        Ingrediente(nome: 'Formaggio a fette', quantita: '1', unitaMisura: 'fetta'),
        Ingrediente(nome: 'Caffè', quantita: '1', unitaMisura: 'tazza'),
      ],
      categoria: 'Colazione',
      tempoPreparazione: '5',
      difficolta: 1,
      quantita: '1 porzione',
      isPredefinita: true,
    ),
    Ricette(
      id: '4',
      titolo: 'Burger di Manzo',
      preparazione: 'Gustoso burger di manzo servito in pane morbido con formaggio cheddar fuso, lattuga fresca, pomodoro e salse a scelta.',
      ingredienti: [
        Ingrediente(nome: 'Pane da hamburger', quantita: '2', unitaMisura: 'pz'),
        Ingrediente(nome: 'Svizzera di manzo', quantita: '2', unitaMisura: 'pz'),
        Ingrediente(nome: 'Lattuga', quantita: '2', unitaMisura: 'foglie'),
        Ingrediente(nome: 'Pomodoro', quantita: '1', unitaMisura: 'pz'),
        Ingrediente(nome: 'Formaggio Cheddar', quantita: '2', unitaMisura: 'fette'),
        Ingrediente(nome: 'Ketchup', quantita: 'q.b.', unitaMisura: ''),
        Ingrediente(nome: 'Maionese', quantita: 'q.b.', unitaMisura: ''),
      ],
      categoria: 'Secondo Piatto',
      tempoPreparazione: '20',
      difficolta: 3,
      quantita: '2 porzioni',
      isPredefinita: true,
    ),
    Ricette(
      id: '5',
      titolo: 'Zuppa di Lenticchie',
      preparazione: 'Una zuppa calda e nutriente preparata con lenticchie secche, un soffritto classico di verdure e brodo vegetale.',
      ingredienti: [
        Ingrediente(nome: 'Lenticchie', quantita: '250', unitaMisura: 'g'),
        Ingrediente(nome: 'Carote', quantita: '1', unitaMisura: 'pz'),
        Ingrediente(nome: 'Sedano', quantita: '1', unitaMisura: 'costa'),
        Ingrediente(nome: 'Cipolla', quantita: '0.5', unitaMisura: 'pz'),
        Ingrediente(nome: 'Brodo vegetale', quantita: '1', unitaMisura: 'L'),
        Ingrediente(nome: 'Olio extravergine', quantita: '2', unitaMisura: 'cucchiai'),
      ],
      categoria: 'Piatto Unico',
      tempoPreparazione: '45',
      difficolta: 1,
      quantita: '4 porzioni',
      isPredefinita: true,
    ),
    Ricette(
      id: '6',
      titolo: 'Yogurt con Frutta',
      preparazione: 'Uno spuntino sano e fresco a base di yogurt greco cremoso, dolcificato con miele e guarnito con frutta fresca e granola.',
      ingredienti: [
        Ingrediente(nome: 'Yogurt greco', quantita: '150', unitaMisura: 'g'),
        Ingrediente(nome: 'Miele', quantita: '1', unitaMisura: 'cucchiaio'),
        Ingrediente(nome: 'Fragole', quantita: '50', unitaMisura: 'g'),
        Ingrediente(nome: 'Mirtilli', quantita: '30', unitaMisura: 'g'),
        Ingrediente(nome: 'Granola', quantita: '2', unitaMisura: 'cucchiai'),
      ],
      categoria: 'Spuntino',
      tempoPreparazione: '5',
      difficolta: 1,
      quantita: '1 porzione',
      isPredefinita: true,
    ),
    Ricette(
      id: '7',
      titolo: 'Frutta Secca',
      preparazione: 'Un mix energetico e nutriente di frutta secca a guscio, ideale per una ricarica rapida durante la giornata.',
      ingredienti: [
        Ingrediente(nome: 'Mandorle', quantita: '10', unitaMisura: 'g'),
        Ingrediente(nome: 'Noci', quantita: '10', unitaMisura: 'g'),
        Ingrediente(nome: 'Nocciole', quantita: '10', unitaMisura: 'g'),
        Ingrediente(nome: 'Anacardi', quantita: '10', unitaMisura: 'g'),
      ],
      categoria: 'Spuntino',
      tempoPreparazione: '2',
      difficolta: 1,
      quantita: '1 porzione',
      isPredefinita: true,
    ),
    Ricette(
      id: '8',
      titolo: 'Torta al Cioccolato',
      preparazione: 'Una torta soffice e golosa ricca di cioccolato, perfetta per la colazione, la merenda o come dessert di fine pasto.',
      ingredienti: [
        Ingrediente(nome: 'Farina', quantita: '200', unitaMisura: 'g'),
        Ingrediente(nome: 'Zucchero', quantita: '150', unitaMisura: 'g'),
        Ingrediente(nome: 'Cacao amaro', quantita: '50', unitaMisura: 'g'),
        Ingrediente(nome: 'Burro', quantita: '100', unitaMisura: 'g'),
        Ingrediente(nome: 'Uova', quantita: '3', unitaMisura: 'pz'),
        Ingrediente(nome: 'Lievito per dolci', quantita: '1', unitaMisura: 'bustina'),
      ],
      categoria: 'Dolce',
      tempoPreparazione: '60',
      difficolta: 3,
      quantita: '8 porzioni',
      isPredefinita: true,
    ),
    Ricette(
      id: '9',
      titolo: 'Gelato alla Vaniglia',
      preparazione: 'Un dessert classico e rinfrescante con gelato cremoso alla vaniglia, eventualmente guarnito con topping a scelta.',
      ingredienti: [
        Ingrediente(nome: 'Gelato alla vaniglia', quantita: '200', unitaMisura: 'g'),
        Ingrediente(nome: 'Cialda', quantita: '2', unitaMisura: 'pz'),
        Ingrediente(nome: 'Topping al cioccolato', quantita: 'q.b.', unitaMisura: ''),
        Ingrediente(nome: 'Granella di nocciole', quantita: 'q.b.', unitaMisura: ''),
      ],
      categoria: 'Dolce',
      tempoPreparazione: '5',
      difficolta: 1,
      quantita: '2 porzioni',
      isPredefinita: true,
    ),
  ];

  // Inizializza i dati caricandoli dalla memoria locale.
  // Se la memoria è vuota (primo avvio), carica le ricette predefinite e le salva.
  Future<void> _inizializzaDati() async {
    final datiSalvati = await _servizio.caricaRicette(); // Tentiamo di leggere dal database
    _ricette.clear(); // Puliamo la lista in memoria prima di ricaricare
    
    if (datiSalvati.isEmpty) {
      // Se non abbiamo trovato nulla, siamo al primo avvio: popoliamo con le ricette di base
      _ricette.addAll(_ricettePredefinite);
      await _salvaSuDisco(); // E le salviamo subito
    } else {
      // Altrimenti usiamo i dati che l'utente aveva salvato
      _ricette.addAll(datiSalvati);
    }
    
    notifyListeners(); // Avvisa l'interfaccia utente che le ricette sono pronte
  }

  // Metodo privato per salvare la lista corrente su SharedPreferences
  Future<void> _salvaSuDisco() async {
    await _servizio.salvaRicette(_ricette);
  }

  // Aggiunge una nuova ricetta al ricettacolo
  void aggiungiRicetta(Ricette nuovaRicetta) {
    _ricette.add(nuovaRicetta); // Aggiunge in coda alla lista
    _salvaSuDisco(); // Riscrive l'intero file per includere la novità
    notifyListeners(); // Ricarica la grafica
  }

  // Rimuove una ricetta in base all'ID
  void rimuoviRicetta(String id) {
    _ricette.removeWhere((ricetta) => ricetta.id == id); // Rimuove solo la ricetta con quell'ID esatto
    _salvaSuDisco();
    notifyListeners();
  }

  // Modifica una ricetta esistente sostituendola
  void modificaRicettaCompleta(Ricette ricettaModificata) {
    // Cerchiamo l'indice della ricetta da modificare all'interno della lista usando l'ID univoco
    final indice = _ricette.indexWhere((r) => r.id == ricettaModificata.id);
    
    if (indice != -1) { // Se l'indice non è -1, la ricetta esiste
      _ricette[indice] = ricettaModificata; // Sovrascriviamo l'elemento intero
      _salvaSuDisco(); // Confermiamo il salvataggio
      notifyListeners();
    }
  }

  // Restituisce una singola ricetta dato il suo ID (molto utile per accoppiamenti)
  Ricette? ottieniRicettaPerId(String id) {
    try {
      // firstWhere cerca il primo elemento che soddisfa la condizione, lancia eccezione se fallisce
      return _ricette.firstWhere((r) => r.id == id);
    } catch (_) {
      // Se non trova la ricetta (es. è stata eliminata dal db), restituisce null in sicurezza
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
  // Funzione per filtrare la lista delle ricette in base a una stringa di ricerca
  List<Ricette> cercaRicette(String query) {
    if (query.isEmpty) {
      return _ricette; // Se la ricerca è vuota, mostriamo tutte le ricette senza filtri
    }
    
    String q = query.toLowerCase(); // Convertiamo in minuscolo per una ricerca insensibile alle maiuscole
    
    return _ricette.where((r) =>
        r.titolo.toLowerCase().contains(q) || // Cerca nel titolo
        r.preparazione.toLowerCase().contains(q) || // Cerca nel testo della preparazione
        r.ingredienti.any((ing) => ing.nome.toLowerCase().contains(q)) // Cerca in qualsiasi degli ingredienti contenuti
    ).toList();
  }
}
