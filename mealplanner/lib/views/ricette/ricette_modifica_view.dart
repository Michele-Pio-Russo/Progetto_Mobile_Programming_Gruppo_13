import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importato per i formatter di testo
import 'package:provider/provider.dart';
import '../../viewmodels/ricette_viewmodel.dart';
import '../../viewmodels/piano_pasti_viewmodel.dart';
import '../../models/ricette_model.dart';
import '../../theme/style.dart';


// Classe di supporto interna per gestire in modo indipendente i controller di ogni singola riga di ingrediente.
// Permette di aggiungere e rimuovere dinamicamente gli ingredienti nella maschera di modifica.
class _IngredienteRiga {
  // Controller per catturare il nome del singolo ingrediente digitato dall'utente
  final TextEditingController nomeCtrl = TextEditingController(); 
  
  // Controller per catturare la quantità numerica (o testuale se 'q.b.')
  final TextEditingController quantitaCtrl = TextEditingController(); 
  
  // Valore di default dell'unità di misura selezionata per questa riga
  String unitaMisura = 'g'; 

  // Metodo per liberare la memoria dei controller testuali quando la riga viene cancellata.
  // Fondamentale per evitare memory leaks in Flutter.
  void dispose() {
    nomeCtrl.dispose();
    quantitaCtrl.dispose();
  }
}

// Schermata responsabile dell'inserimento di una nuova ricetta o della modifica di una esistente.
// Il comportamento (Salva vs Modifica) varia dinamicamente se viene passata una [Ricette] al costruttore.
class RicetteModificaView extends StatefulWidget {
  final Ricette?
  ricetta; // Se è null siamo in modalità "Aggiungi", altrimenti "Modifica"

  // Costruttore della schermata: accetta opzionalmente una ricetta da modificare
  const RicetteModificaView({super.key, this.ricetta});

  @override
  State<RicetteModificaView> createState() => _RicetteModificaViewState();
}

// Stato per la gestione della schermata di aggiunta/modifica ricetta
class _RicetteModificaViewState extends State<RicetteModificaView> {
  // Chiave globale per identificare univocamente il Form e permetterne la validazione.
  final _formKey = GlobalKey<FormState>(); 

  // --- Controller Testuali ---
  // Controller per il nome principale della ricetta
  late TextEditingController _titoloController; 
  
  // Controller per le istruzioni dettagliate (il procedimento)
  late TextEditingController _preparazioneController; 
  
  // Controller per i minuti stimati di preparazione
  late TextEditingController _tempoPreparazioneController; 
  
  // Controller per il numero di porzioni (es. "2 persone")
  late TextEditingController _quantitaController; 
  
  // Controller per eventuali suggerimenti e annotazioni opzionali
  late TextEditingController _noteController; 
  
  // Lista dinamica che mantiene lo stato di tutte le righe di ingredienti visibili
  final List<_IngredienteRiga> _ingredientiRighe = []; 

  // Memorizza temporaneamente la categoria selezionata dal DropdownButton
  String? _categoriaSelezionata; 
  
  // Valore della difficoltà espresso da 1 a 5. Di default è 1.
  int _difficoltaSelezionata = 1; 

  // Getter di comodità per stabilire in modo leggibile se siamo in modalità Modifica.
  // Ritorna `true` se al costruttore del widget padre è stata passata una ricetta esistente.
  bool get eModalitaModifica => widget.ricetta != null;

  // Inizializza lo stato del componente.
  // Se stiamo modificando, pre-popola tutti i [TextEditingController] con i dati preesistenti.
  // Altrimenti li inizializza vuoti.
  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController(text: widget.ricetta?.titolo ?? '');
    _preparazioneController = TextEditingController(text: widget.ricetta?.preparazione ?? '');
    _tempoPreparazioneController = TextEditingController(text: widget.ricetta?.tempoPreparazione ?? '');
    _quantitaController = TextEditingController(text: widget.ricetta?.quantita ?? '');
    _noteController = TextEditingController(text: widget.ricetta?.note ?? '');
    _difficoltaSelezionata = widget.ricetta?.difficolta ?? 1;

    // Gestione Iniziale Ingredienti:
    if (widget.ricetta != null && widget.ricetta!.ingredienti.isNotEmpty) {
      // Caso 1: Modifica ricetta. Iteriamo su tutti i vecchi ingredienti e creiamo i controller per l'interfaccia.
      for (var ing in widget.ricetta!.ingredienti) {
        final riga = _IngredienteRiga();
        riga.nomeCtrl.text = ing.nome;
        riga.quantitaCtrl.text = ing.quantita;

        // Implementiamo una logica di tolleranza all'errore per le unità di misura.
        // Se il valore nel database non corrisponde a nessuno dei valori ammessi nel menù a tendina, 
        // lo facciamo ricadere (fallback) sul valore sicuro 'altro' per non generare un crash dell'app.
        riga.unitaMisura = ing.unitaMisura.isEmpty
            ? 'g'
            : (['g', 'kg', 'ml', 'L', 'pz', 'cucchiai', 'q.b.', 'fette', 'spicchio', 'cespo', 'tazza', 'foglie', 'costa', 'bustina', 'altro']
                .contains(ing.unitaMisura) ? ing.unitaMisura : 'altro');
        _ingredientiRighe.add(riga);
      }
    } else {
      // Caso 2: Nuova ricetta. Inseriamo subito una riga vuota pronta all'uso.
      _ingredientiRighe.add(_IngredienteRiga());
    }

    _categoriaSelezionata = widget.ricetta?.categoria;
  }

  // Override del metodo dispose: chiamato prima che il widget venga distrutto in modo permanente.
  // Scopo critico: pulire la RAM deallocando tutti i controller di testo e le relative righe figlie.
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

  // Metodo invocato quando l'utente clicca sul pulsante "+" per aggiungere ingredienti extra.
  // Triggera un [setState] che spinge Flutter a ridisegnare la lista `_ingredientiRighe`.
  void _aggiungiIngrediente() {
    setState(() {
      _ingredientiRighe.add(_IngredienteRiga());
    });
  }

  // Cancella uno specifico ingrediente dall'elenco basandosi sul suo `index`.
  // Se l'utente rimuove l'ultimo ingrediente disponibile, rimpiazziamo immediatamente
  // con uno nuovo vuoto, per evitare bug di interfaccia (nessun form visibile).
  void _rimuoviIngrediente(int index) {
    setState(() {
      _ingredientiRighe[index].dispose(); // Pulizia risorsa singola
      _ingredientiRighe.removeAt(index);
      
      // Meccanismo di sicurezza: ci deve essere sempre almeno una riga compilabile
      if (_ingredientiRighe.isEmpty) {
        _ingredientiRighe.add(_IngredienteRiga());
      }
    });
  }

  // Helper Dialog: Mostra un pop-up di avviso prima di eliminare definitivamente una ricetta.
  // Contiene logica di pulizia aggiuntiva collegata ai pasti pianificati.
  void _mostraConfermaEliminazione(BuildContext context, RicetteViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Eliminare ricetta?'),
          content: Text(
            'Sei sicuro di voler eliminare la ricetta "${widget.ricetta!.titolo}"? L\'operazione non può essere annullata.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyle.raggioCard),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla', style: TextStyle(color: AppStyle.coloreTestoSecondario)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyle.coloreErrore,
                foregroundColor: AppStyle.coloreBianco,
              ),
              onPressed: () {
                // Azione Distruttiva:
                // 1. Eliminiamo fisicamente la ricetta dalla base di dati in memoria.
                viewModel.rimuoviRicetta(widget.ricetta!.id);
                // 2. IMPORTANTISSIMO: Se la ricetta era stata precedentemente programmata nel calendario,
                // rimuoviamo il collegamento dai PastiPianificati (Effetto Cascata) per evitare crash
                // derivati da RecipeNotFound exceptions.
                Provider.of<PianoPastiViewModel>(context, listen: false).rimuoviRiferimentiRicetta(widget.ricetta!.id);
                
                // Rimuoviamo il pop-up e poi usciamo dalla schermata di modifica
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Elimina'),
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        // Mostriamo un dialogo per chiedere conferma se davvero si vuole uscire perdendo le modifiche
        final bool shouldPop = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Scartare le modifiche?'),
                content: const Text(
                  'Uscendo perderai tutte le modifiche non salvate. Continuare?',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyle.raggioCard),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(
                      false,
                    ), // Annulla e rimane nella schermata di modifica
                    child: const Text(
                      'Annulla',
                      style: TextStyle(color: AppStyle.coloreTestoSecondario),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyle.coloreErrore,
                      foregroundColor: AppStyle.coloreBianco,
                    ),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(true), // Conferma l'uscita dalla schermata
                    child: const Text('Esci senza salvare'),
                  ),
                ],
              ),
            ) ??
            false; // Se il dialogo viene chiuso toccando fuori, blocca l'uscita per sicurezza
            
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            eModalitaModifica ? 'Modifica Ricetta' : 'Nuova Ricetta',
          ),
          actions: [
            if (eModalitaModifica)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppStyle.coloreErrore),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Impedisce fisicamente l'inserimento di lettere o simboli
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Tempo di preparazione* (minuti)',
                  ),
                  validator: (valore) {
                    if (valore == null || valore.trim().isEmpty) {
                      return 'Inserisci il tempo di preparazione in minuti';
                    }
                    return null;
                  },
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
                        Icons.local_fire_department_outlined,
                        color: index < _difficoltaSelezionata
                            ? Colors.orange
                            : AppStyle.coloreTestoSecondario.withValues(alpha: 0.2),
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
                    labelText: 'Quantità (es. 2 porzioni)',
                  ),
                ),
                const SizedBox(height: 16),

                // Preparazione
                TextFormField(
                  controller: _preparazioneController,
                  decoration: const InputDecoration(
                    labelText: 'Procedimento (Preparazione)',
                  ),
                  maxLines: 3,
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
                                borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
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
                              hintText: 'Quantità',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
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
                            initialValue: riga.unitaMisura,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
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
                              if (val != null) {
                                setState(() => riga.unitaMisura = val);
                              }
                            },
                          ),
                        ),
                        if (_ingredientiRighe.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: AppStyle.coloreErrore,
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
                      backgroundColor: AppStyle.coloreTestoSecondario.withValues(alpha: 0.1),
                      foregroundColor: AppStyle.coloreTestoPrincipale,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
                      ),
                    ),
                    onPressed: _aggiungiIngrediente,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Aggiungi'),
                  ),
                ),
                const SizedBox(height: 40),

                // Bottone Salva
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
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
                                unitaMisura: r
                                    .unitaMisura, // Aggiungiamo l'unità di misura scelta
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
                            backgroundColor: AppStyle.colorePrimario,
                          ),
                        );

                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      eModalitaModifica ? 'Salva modifiche' : 'Salva ricetta',
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