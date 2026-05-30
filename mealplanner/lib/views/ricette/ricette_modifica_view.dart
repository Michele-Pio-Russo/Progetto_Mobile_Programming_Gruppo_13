import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/ricette_viewmodel.dart';
import '../../viewmodels/piano_pasti_viewmodel.dart';
import '../../models/ricette_model.dart';

// Classe di supporto interna per mantenere i controller di ogni singola riga di ingrediente
class _IngredienteRiga {
  final TextEditingController nomeCtrl = TextEditingController(); // Controller per catturare il nome del singolo ingrediente
  final TextEditingController quantitaCtrl = TextEditingController(); // Controller per catturare la quantità numerica del singolo ingrediente
  String unitaMisura = 'g'; // Valore di default dell'unità di misura per questa riga

  // Metodo per liberare la memoria quando la riga non serve più
  void dispose() {
    nomeCtrl.dispose();
    quantitaCtrl.dispose();
  }
}

// Classe che gestisce la schermata per aggiungere o modificare una ricetta
class RicetteModificaView extends StatefulWidget {
  final Ricette? ricetta; // Se è null siamo in modalità "Aggiungi", altrimenti "Modifica"

  // Costruttore della schermata: accetta opzionalmente una ricetta da modificare
  const RicetteModificaView({super.key, this.ricetta});

  @override
  State<RicetteModificaView> createState() => _RicetteModificaViewState();
}

// Stato per la gestione della schermata di aggiunta/modifica ricetta
class _RicetteModificaViewState extends State<RicetteModificaView> {
  final _formKey = GlobalKey<FormState>(); // Chiave per validare i campi obbligatori del form

  // Controller usati per catturare e leggere i testi digitati dall'utente
  late TextEditingController _titoloController; // Controller per il nome della ricetta
  late TextEditingController _preparazioneController; // Controller per le istruzioni
  late TextEditingController _tempoPreparazioneController; // Controller per i minuti richiesti
  late TextEditingController _quantitaController; // Controller per il numero di porzioni
  late TextEditingController _noteController; // Controller per consigli extra
  final List<_IngredienteRiga> _ingredientiRighe = []; // Lista per gestire dinamicamente più righe di ingredienti

  String? _categoriaSelezionata; // Memorizza la categoria scelta dal menù a tendina
  int _difficoltaSelezionata = 1; // Fiammelle da 1 a 5 (default 1)

  // Proprietà helper per capire se stiamo creando una nuova ricetta o modificandone una esistente
  bool get eModalitaModifica => widget.ricetta != null;

  // Inizializza lo stato e riempie i campi di testo se stiamo modificando una ricetta esistente
  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController(
      text: widget.ricetta?.titolo ?? '',
    );
    _preparazioneController = TextEditingController(
      text: widget.ricetta?.preparazione ?? '',
    );
    _tempoPreparazioneController = TextEditingController(
      text: widget.ricetta?.tempoPreparazione ?? '',
    );
    _quantitaController = TextEditingController(
      text: widget.ricetta?.quantita ?? '',
    );
    _noteController = TextEditingController(text: widget.ricetta?.note ?? '');
    _difficoltaSelezionata = widget.ricetta?.difficolta ?? 1;

    // Inizializza i controller per gli ingredienti
    if (widget.ricetta != null && widget.ricetta!.ingredienti.isNotEmpty) {
      // Se la ricetta esiste già, leggiamo i vecchi ingredienti e creiamo una riga per ciascuno
      for (var ing in widget.ricetta!.ingredienti) {
        final riga = _IngredienteRiga();
        riga.nomeCtrl.text = ing.nome;
        riga.quantitaCtrl.text = ing.quantita;
        
        // Mettiamo un controllo di sicurezza per non far schiantare il menu a tendina se il valore è vecchio o corrotto
        riga.unitaMisura = ing.unitaMisura.isEmpty
            ? 'g'
            : ([
                    'g',
                    'kg',
                    'ml',
                    'L',
                    'pz',
                    'cucchiai',
                    'q.b.',
                    'fette',
                    'spicchio',
                    'cespo',
                    'tazza',
                    'foglie',
                    'costa',
                    'bustina',
                    'altro',
                  ].contains(ing.unitaMisura)
                  ? ing.unitaMisura
                  : 'altro');
        _ingredientiRighe.add(riga);
      }
    } else {
      _ingredientiRighe.add(_IngredienteRiga()); // Almeno uno vuoto
    }

    _categoriaSelezionata = widget.ricetta?.categoria;
  }

  // Libera la memoria chiudendo tutti i controller quando la schermata viene chiusa
  @override
  void dispose() {
    _titoloController.dispose();
    _preparazioneController.dispose();
    _tempoPreparazioneController.dispose();
    _quantitaController.dispose();
    _noteController.dispose();
    for (var riga in _ingredientiRighe) {
      riga.dispose();
    }
    super.dispose();
  }

  // Aggiunge una nuova riga vuota per permettere l'inserimento di un ingrediente extra
  void _aggiungiIngrediente() {
    setState(() {
      _ingredientiRighe.add(_IngredienteRiga());
    });
  }

  // Rimuove la riga di un ingrediente e si assicura che ne rimanga sempre almeno una vuota
  void _rimuoviIngrediente(int index) {
    setState(() {
      _ingredientiRighe[index].dispose();
      _ingredientiRighe.removeAt(index);
      if (_ingredientiRighe.isEmpty) {
        _ingredientiRighe.add(_IngredienteRiga());
      }
    });
  }

  // Mostra un popup di conferma quando l'utente preme il tasto rosso di eliminazione della ricetta
  void _mostraConfermaEliminazione(
    BuildContext context,
    RicetteViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Eliminare ricetta?'),
          content: Text(
            'Sei sicuro di voler eliminare la ricetta "${widget.ricetta!.titolo}"? L\'operazione non può essere annullata.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Annulla',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                viewModel.rimuoviRicetta(widget.ricetta!.id);
                Provider.of<PianoPastiViewModel>(
                  context,
                  listen: false,
                ).rimuoviRiferimentiRicetta(widget.ricetta!.id);
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text(
                'Elimina',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Metodo principale che costruisce e disegna l'intera interfaccia grafica della schermata
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RicetteViewModel>(context, listen: false);

    return WillPopScope( // WillPopScope serve per intercettare quando l'utente preme il tasto indietro del telefono (o fa lo swipe)
      onWillPop: () async {
        // Mostriamo un dialogo per chiedere conferma se davvero si vuole uscire perdendo le modifiche
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Scartare le modifiche?'),
                content: const Text(
                  'Uscendo perderai tutte le modifiche non salvate. Continuare?',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Annulla e rimane nella schermata di modifica
                    child: const Text(
                      'Annulla',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => Navigator.of(context).pop(true), // Conferma l'uscita dalla schermata
                    child: const Text(
                      'Esci senza salvare',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ) ??
            false; // Se il dialogo viene chiuso toccando fuori, blocca l'uscita per sicurezza
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            eModalitaModifica ? 'Modifica Ricetta' : 'Nuova Ricetta',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            if (eModalitaModifica)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _mostraConfermaEliminazione(context, viewModel);
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Titolo
                TextFormField(
                  controller: _titoloController,
                  decoration: const InputDecoration(labelText: 'Titolo*'),
                  validator: (valore) => (valore == null || valore.isEmpty)
                      ? 'Inserisci il titolo'
                      : null,
                ),
                const SizedBox(height: 16),

                // Categoria
                DropdownButtonFormField<String>(
                  initialValue: _categoriaSelezionata,
                  decoration: const InputDecoration(labelText: 'Categoria*'),
                  items: Ricette.categorie.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (valore) =>
                      setState(() => _categoriaSelezionata = valore),
                  validator: (valore) =>
                      valore == null ? 'Seleziona una categoria' : null,
                ),
                const SizedBox(height: 16),

                // Tempo di preparazione
                TextFormField(
                  controller: _tempoPreparazioneController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tempo di preparazione* (minuti)',
                  ),
                  validator: (valore) => (valore == null || valore.isEmpty)
                      ? 'Inserisci il tempo di preparazione in minuti'
                      : null,
                ),
                const SizedBox(height: 16),

                // Difficoltà
                const Text(
                  'Difficoltà*',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.local_fire_department,
                        color: index < _difficoltaSelezionata
                            ? Colors.orange
                            : Colors.grey.shade300,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          _difficoltaSelezionata = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Quantità
                TextFormField(
                  controller: _quantitaController,
                  decoration: const InputDecoration(
                    labelText: 'Quantità* (es. 2 porzioni)',
                  ),
                  validator: (valore) => (valore == null || valore.isEmpty)
                      ? 'Inserisci la quantità o il numero di porzioni'
                      : null,
                ),
                const SizedBox(height: 16),

                // Preparazione
                TextFormField(
                  controller: _preparazioneController,
                  decoration: const InputDecoration(
                    labelText: 'Procedimento (Preparazione)*',
                  ),
                  maxLines: 3,
                  validator: (valore) => (valore == null || valore.isEmpty)
                      ? 'Inserisci il procedimento'
                      : null,
                ),
                const SizedBox(height: 16),

                // Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (Opzionale)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Ingredienti
                const Text(
                  'Ingredienti*',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...List.generate(_ingredientiRighe.length, (index) {
                  final riga = _ingredientiRighe[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        // Nome
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: riga.nomeCtrl,
                            decoration: InputDecoration(
                              hintText: 'Nome (es. Farina)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            validator: (valore) {
                              if (index == 0 &&
                                  (valore == null || valore.trim().isEmpty)) {
                                return 'Inserisci nome';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Quantità
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: riga.quantitaCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Q.tà',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            validator: (valore) {
                              if (riga.nomeCtrl.text.isNotEmpty &&
                                  (valore == null || valore.trim().isEmpty)) {
                                return 'Obbligatorio';
                              }
                              if (valore != null &&
                                  valore.isNotEmpty &&
                                  double.tryParse(valore) == null &&
                                  riga.unitaMisura != 'q.b.') {
                                return 'Numero';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Unità
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: riga.unitaMisura,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            isExpanded: true,
                            items:
                                [
                                  'g',
                                  'kg',
                                  'ml',
                                  'L',
                                  'pz',
                                  'cucchiai',
                                  'q.b.',
                                  'fette',
                                  'spicchio',
                                  'cespo',
                                  'tazza',
                                  'foglie',
                                  'costa',
                                  'bustina',
                                  'altro',
                                ].map((u) {
                                  return DropdownMenuItem(
                                    value: u,
                                    child: Text(
                                      u,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null)
                                setState(() => riga.unitaMisura = val);
                            },
                          ),
                        ),
                        if (_ingredientiRighe.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _rimuoviIngrediente(index),
                          ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      shape: const StadiumBorder(), // Bottone ovale
                    ),
                    onPressed: _aggiungiIngrediente,
                    icon: const Icon(Icons.add),
                    label: const Text('Aggiungi'),
                  ),
                ),
                const SizedBox(height: 40),

                // Bottone Salva
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.black, // Uniformato con piano_pasti
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Controlliamo che tutti i campi del form obbligatori (quelli con l'asterisco) siano validati
                      if (_formKey.currentState!.validate()) {
                        
                        // Raccogliamo tutti i dati inseriti dall'utente per gli ingredienti 
                        // Ignoriamo le righe dove il nome dell'ingrediente è stato lasciato vuoto
                        List<Ingrediente> listaIngredienti = _ingredientiRighe
                            .where((r) => r.nomeCtrl.text.trim().isNotEmpty)
                            .map(
                              (r) => Ingrediente(
                                nome: r.nomeCtrl.text.trim(),
                                quantita: r.quantitaCtrl.text.trim(),
                                unitaMisura: r.unitaMisura, // Aggiungiamo l'unità di misura scelta
                              ),
                            )
                            .toList();

                        // Verifica di sicurezza finale per la validazione manuale degli ingredienti
                        if (listaIngredienti.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Inserisci almeno un ingrediente valido',
                              ),
                            ),
                          );
                          return; // Interrompiamo il salvataggio
                        }

                        if (eModalitaModifica) {
                          final ricettaAggiornata = widget.ricetta!.copia(
                            titolo: _titoloController.text,
                            preparazione: _preparazioneController.text,
                            categoria: _categoriaSelezionata!,
                            tempoPreparazione:
                                _tempoPreparazioneController.text,
                            difficolta: _difficoltaSelezionata,
                            quantita: _quantitaController.text,
                            note: _noteController.text,
                            ingredienti: listaIngredienti,
                          );
                          viewModel.modificaRicettaCompleta(ricettaAggiornata);
                        } else {
                          final nuovaRicetta = Ricette(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            titolo: _titoloController.text,
                            preparazione: _preparazioneController.text,
                            categoria: _categoriaSelezionata!,
                            tempoPreparazione:
                                _tempoPreparazioneController.text,
                            difficolta: _difficoltaSelezionata,
                            quantita: _quantitaController.text,
                            note: _noteController.text,
                            ingredienti: listaIngredienti,
                          );
                          viewModel.aggiungiRicetta(nuovaRicetta);
                        }

                        // Mostra il banner verde di successo nella parte bassa dello schermo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ricetta salvata con successo!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      eModalitaModifica ? 'Salva modifiche' : 'Salva ricetta',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
