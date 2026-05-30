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
  late TextEditingController _preparazioneController;
  final List<TextEditingController> _ingredientiControllers = [];

  String? _categoriaSelezionata;

  bool get eModalitaModifica => widget.ricetta != null;

  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController(text: widget.ricetta?.titolo ?? '');
    _preparazioneController = TextEditingController(text: widget.ricetta?.preparazione ?? '');
    
    // Inizializza i controller per gli ingredienti
    if (widget.ricetta != null && widget.ricetta!.ingredienti.isNotEmpty) {
      for (String ing in widget.ricetta!.ingredienti) {
        _ingredientiControllers.add(TextEditingController(text: ing));
      }
    } else {
      _ingredientiControllers.add(TextEditingController()); // Almeno uno vuoto
    }
    
    _categoriaSelezionata = widget.ricetta?.categoria;
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _preparazioneController.dispose();
    for (var controller in _ingredientiControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _aggiungiIngrediente() {
    setState(() {
      _ingredientiControllers.add(TextEditingController());
    });
  }

  void _rimuoviIngrediente(int index) {
    setState(() {
      _ingredientiControllers[index].dispose();
      _ingredientiControllers.removeAt(index);
      if (_ingredientiControllers.isEmpty) {
        _ingredientiControllers.add(TextEditingController());
      }
    });
  }

  void _mostraConfermaEliminazione(BuildContext context, RicetteViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Eliminare ricetta?'),
          content: Text('Sei sicuro di voler eliminare la ricetta "${widget.ricetta!.titolo}"? L\'operazione non può essere annullata.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                viewModel.rimuoviRicetta(widget.ricetta!.id);
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Elimina', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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

              // Preparazione
              TextFormField(
                controller: _preparazioneController,
                decoration: const InputDecoration(labelText: 'Preparazione*'),
                maxLines: 3,
                validator: (valore) => (valore == null || valore.isEmpty) ? 'Inserisci una preparazione' : null,
              ),
              const SizedBox(height: 16),

              // Ingredienti
              const Text('Ingredienti*', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...List.generate(_ingredientiControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ingredientiControllers[index],
                          decoration: InputDecoration(
                            hintText: 'Es. 200g Farina',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          validator: (valore) {
                            if (index == 0 && (valore == null || valore.trim().isEmpty)) {
                              return 'Inserisci almeno un ingrediente';
                            }
                            return null;
                          },
                        ),
                      ),
                      if (_ingredientiControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
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
                    backgroundColor: Colors.black, // Uniformato con piano_pasti
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Estrapoliamo i testi dai controller degli ingredienti
                      List<String> listaIngredienti = _ingredientiControllers
                          .map((c) => c.text.trim())
                          .where((i) => i.isNotEmpty)
                          .toList();

                      if (listaIngredienti.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Inserisci almeno un ingrediente valido')),
                        );
                        return;
                      }

                      if (eModalitaModifica) {
                        final ricettaAggiornata = widget.ricetta!.copia(
                          titolo: _titoloController.text,
                          preparazione: _preparazioneController.text,
                          categoria: _categoriaSelezionata!,
                          ingredienti: listaIngredienti,
                        );
                        viewModel.modificaRicettaCompleta(ricettaAggiornata);
                      } else {
                        final nuovaRicetta = Ricette(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          titolo: _titoloController.text,
                          preparazione: _preparazioneController.text,
                          categoria: _categoriaSelezionata!,
                          ingredienti: listaIngredienti,
                        );
                        viewModel.aggiungiRicetta(nuovaRicetta);
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: Text(eModalitaModifica ? 'Salva modifiche' : 'Salva ricetta', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
