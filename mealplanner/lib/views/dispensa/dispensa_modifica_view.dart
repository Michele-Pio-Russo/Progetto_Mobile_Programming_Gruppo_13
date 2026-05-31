import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dispensa_viewmodel.dart';
import '../../models/dispensa_model.dart';
import '../../theme/style.dart';


class SchermataModificaProdotto extends StatefulWidget {
  final Dispensa? articolo; // Se è null siamo in modalità "Aggiungi", altrimenti "Modifica"

  const SchermataModificaProdotto({super.key, this.articolo});

  @override
  State<SchermataModificaProdotto> createState() => _SchermataModificaProdottoState();
}

class _SchermataModificaProdottoState extends State<SchermataModificaProdotto> {
  final _formKey = GlobalKey<FormState>(); // Serve per validare i campi obbligatori

  // Controller per leggere il testo digitato dall'utente
  late TextEditingController _nomeController;
  late TextEditingController _quantitaController;

  // Variabili per salvare le scelte dei menu a tendina e della data
  String? _categoriaSelezionata;
  String? _unitaSelezionata;
  DateTime? _dataScadenzaSelezionata;

  bool get eModalitaModifica => widget.articolo != null;

  @override
  void initState() {
    super.initState();
    // Se stiamo modificando un articolo, precompiliamo i campi con i suoi dati veri
    // Se lo stiamo aggiungendo, la pagina riceve un articolo null
    _nomeController = TextEditingController(text: widget.articolo?.nome ?? '');
    _quantitaController = TextEditingController(text: widget.articolo?.quantita.toString() ?? '');
    _categoriaSelezionata = widget.articolo?.categoria;
    _unitaSelezionata = widget.articolo?.unita;
    _dataScadenzaSelezionata = widget.articolo?.scadenza;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantitaController.dispose();
    super.dispose();
  }

  // Funzione per mostrare il calendario di sistema
  Future<void> _selezionaData(BuildContext context) async {
    final dataScelta = await showDatePicker(
      context: context,
      initialDate: _dataScadenzaSelezionata ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (dataScelta != null) {
      setState(() {
        _dataScadenzaSelezionata = dataScelta;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gestore = Provider.of<GestoreDispensa>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(eModalitaModifica ? 'Modifica Prodotto' : 'Nuovo Prodotto'),
        actions: [
          // Se siamo in modalità modifica, mostriamo il cestino
          if (eModalitaModifica)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppStyle.coloreErrore),
              onPressed: () {
                gestore.rimuoviArticolo(widget.articolo!.id);
                Navigator.pop(context); // Torna alla lista
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
              // Campo Nome Prodotto
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome Prodotto*'),
                validator: (valore) => (valore == null || valore.isEmpty) ? 'Inserisci il nome' : null,
              ),
              const SizedBox(height: 16),

              // Campo Quantità
              TextFormField(
                controller: _quantitaController,
                decoration: const InputDecoration(labelText: 'Quantità*'),
                keyboardType: TextInputType.number, // Mostra la tastiera numerica
                validator: (valore) {
                  if (valore == null || valore.isEmpty) return 'Inserisci la quantità';
                  if (double.tryParse(valore) == null) return 'Inserisci un numero valido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Menu a tendina Unità di Misura (Prende i dati statici dal tuo Modello)
              DropdownButtonFormField<String>(
                initialValue: _unitaSelezionata,
                decoration: const InputDecoration(labelText: 'Unità di misura*'),
                items: Dispensa.unitaDiMisura.map((unita) {
                  return DropdownMenuItem(value: unita, child: Text(unita));
                }).toList(),
                onChanged: (valore) => setState(() => _unitaSelezionata = valore),
                validator: (valore) => valore == null ? 'Seleziona un\'unità' : null,
              ),
              const SizedBox(height: 16),

              // Menu a tendina Categoria
              DropdownButtonFormField<String>(
                initialValue: _categoriaSelezionata,
                decoration: const InputDecoration(labelText: 'Categoria*'),
                items: Dispensa.categorie.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (valore) => setState(() => _categoriaSelezionata = valore),
                validator: (valore) => valore == null ? 'Seleziona una categoria' : null,
              ),
              const SizedBox(height: 24),

              // Selettore Data di Scadenza
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dataScadenzaSelezionata == null
                          ? 'Nessuna scadenza inserita'
                          : 'Scadenza: ${_dataScadenzaSelezionata!.day}/${_dataScadenzaSelezionata!.month}/${_dataScadenzaSelezionata!.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selezionaData(context),
                    child: const Text('Scegli Data'),
                  ),
                  if (_dataScadenzaSelezionata != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: AppStyle.coloreTestoSecondario),
                      onPressed: () => setState(() => _dataScadenzaSelezionata = null),
                    ),
                ],
              ),
              const SizedBox(height: 40),

              // 6. Il tasto SALVA in fondo
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Controlla che tutti i campi obbligatori (*) siano compilati correttamente
                    if (_formKey.currentState!.validate()) {
                      
                      if (eModalitaModifica) {
                        // Se siamo in modalità modifica, viene invocato il metodo copia sull'oggetto Dispensa già esistente...
                        final articoloAggiornato = widget.articolo!.copia(
                          nome: _nomeController.text,
                          quantita: double.parse(_quantitaController.text),
                          unita: _unitaSelezionata!,
                          categoria: _categoriaSelezionata!,
                          scadenza: _dataScadenzaSelezionata,
                          svuotaScadenza: _dataScadenzaSelezionata == null,
                        );
                        
                        gestore.modificaArticoloCompleto(articoloAggiornato);
                      } else {
                        // ...altrimenti, crea un nuovo oggetto Dispensa
                        final nuovoArticolo = Dispensa(
                          id: DateTime.now().millisecondsSinceEpoch.toString(), // Genera un ID univoco basato sul tempo
                          nome: _nomeController.text,
                          quantita: double.parse(_quantitaController.text),
                          unita: _unitaSelezionata!,
                          categoria: _categoriaSelezionata!,
                          scadenza: _dataScadenzaSelezionata,
                        );
                        
                        gestore.aggiungiArticolo(nuovoArticolo);
                      }

                      Navigator.pop(context); // Chiude la schermata e torna alla lista
                    }
                  },
                  child: const Text('SALVA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}