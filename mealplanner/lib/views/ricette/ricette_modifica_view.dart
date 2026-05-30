import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/ricette_viewmodel.dart';
import '../../models/ricette_model.dart';

class RicetteModificaView extends StatefulWidget {
  final Ricette? ricetta; // Se è null siamo in modalità "Aggiungi", altrimenti "Modifica"

  const RicetteModificaView({super.key, this.ricetta});

  @override
  State<RicetteModificaView> createState() => _RicetteModificaViewState();
}

class _RicetteModificaViewState extends State<RicetteModificaView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titoloController;
  late TextEditingController _descrizioneController;
  late TextEditingController _ingredientiController;

  String? _categoriaSelezionata;

  bool get eModalitaModifica => widget.ricetta != null;

  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController(text: widget.ricetta?.titolo ?? '');
    _descrizioneController = TextEditingController(text: widget.ricetta?.descrizione ?? '');
    
    // Per gli ingredienti uniamo la lista in un'unica stringa, separata da ritorni a capo
    String ingredientiTesto = widget.ricetta?.ingredienti.join('\n') ?? '';
    _ingredientiController = TextEditingController(text: ingredientiTesto);
    
    _categoriaSelezionata = widget.ricetta?.categoria;
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _descrizioneController.dispose();
    _ingredientiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RicetteViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(eModalitaModifica ? 'Modifica Ricetta' : 'Nuova Ricetta', 
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (eModalitaModifica)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Rimuove la ricetta
                viewModel.rimuoviRicetta(widget.ricetta!.id);
                Navigator.pop(context);
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
                validator: (valore) => (valore == null || valore.isEmpty) ? 'Inserisci il titolo' : null,
              ),
              const SizedBox(height: 16),

              // Categoria
              DropdownButtonFormField<String>(
                initialValue: _categoriaSelezionata,
                decoration: const InputDecoration(labelText: 'Categoria*'),
                items: Ricette.categorie.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (valore) => setState(() => _categoriaSelezionata = valore),
                validator: (valore) => valore == null ? 'Seleziona una categoria' : null,
              ),
              const SizedBox(height: 16),

              // Descrizione
              TextFormField(
                controller: _descrizioneController,
                decoration: const InputDecoration(labelText: 'Descrizione*'),
                maxLines: 3,
                validator: (valore) => (valore == null || valore.isEmpty) ? 'Inserisci una descrizione' : null,
              ),
              const SizedBox(height: 16),

              // Ingredienti
              TextFormField(
                controller: _ingredientiController,
                decoration: const InputDecoration(
                  labelText: 'Ingredienti*',
                  hintText: 'Inserisci un ingrediente per riga',
                ),
                maxLines: 5,
                validator: (valore) => (valore == null || valore.trim().isEmpty) ? 'Inserisci almeno un ingrediente' : null,
              ),
              const SizedBox(height: 40),

              // Bottone Salva
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Separiamo gli ingredienti per riga, rimuovendo le righe vuote
                      List<String> listaIngredienti = _ingredientiController.text
                          .split('\n')
                          .map((i) => i.trim())
                          .where((i) => i.isNotEmpty)
                          .toList();

                      if (eModalitaModifica) {
                        final ricettaAggiornata = widget.ricetta!.copia(
                          titolo: _titoloController.text,
                          descrizione: _descrizioneController.text,
                          categoria: _categoriaSelezionata!,
                          ingredienti: listaIngredienti,
                        );
                        viewModel.modificaRicettaCompleta(ricettaAggiornata);
                      } else {
                        final nuovaRicetta = Ricette(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          titolo: _titoloController.text,
                          descrizione: _descrizioneController.text,
                          categoria: _categoriaSelezionata!,
                          ingredienti: listaIngredienti,
                        );
                        viewModel.aggiungiRicetta(nuovaRicetta);
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('SALVA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
