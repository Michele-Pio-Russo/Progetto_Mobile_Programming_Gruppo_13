import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/ricette_viewmodel.dart';
import '../../models/ricette_model.dart';
import 'ricette_modifica_view.dart';
import 'ricette_dettaglio_view.dart';

// Schermata principale che elenca tutte le ricette nel ricettacolo
class RicetteView extends StatefulWidget {
  // Costruttore della schermata delle ricette
  const RicetteView({super.key});

  @override
  State<RicetteView> createState() => _RicetteViewState();
}

// Classe per la gestione dello stato della schermata delle ricette
class _RicetteViewState extends State<RicetteView> {
  String _categoriaSelezionata = 'Tutte'; // Salva la categoria corrente selezionata per filtrare
  String _queryRicerca = ''; // Salva il testo cercato dall'utente nella barra in alto
  int? _difficoltaSelezionata; // null significa che vogliamo vedere "Tutte"
  String _tempoSelezionato = 'Tutti'; // Per filtrare il tempo (es. "< 15 min")

  // Disegna l'interfaccia con la barra di ricerca, i filtri e la lista delle ricette
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RicetteViewModel>(context);
    
    // Applichiamo i filtri in sequenza: prima testo, poi categoria, difficoltà e infine il tempo
    
    // 1. Filtraggio tramite barra di ricerca testuale
    List<Ricette> ricetteFiltrate = viewModel.cercaRicette(_queryRicerca);
    
    // 2. Filtraggio tramite categoria
    if (_categoriaSelezionata != 'Tutte') {
      ricetteFiltrate = ricetteFiltrate.where((r) => r.categoria == _categoriaSelezionata).toList();
    }
    
    // 3. Filtraggio tramite livello di difficoltà (fiammelle)
    if (_difficoltaSelezionata != null) {
      ricetteFiltrate = ricetteFiltrate.where((r) => r.difficolta == _difficoltaSelezionata).toList();
    }
    
    // 4. Filtraggio tramite tempo stimato
    if (_tempoSelezionato != 'Tutti') {
      ricetteFiltrate = ricetteFiltrate.where((r) {
        // Il tempo è salvato come testo (es. "20"), proviamo a convertirlo in numero per fare i confronti matematici
        int tempo = int.tryParse(r.tempoPreparazione) ?? 0;
        
        // Applichiamo i raggruppamenti del filtro
        if (_tempoSelezionato == '< 15 min') return tempo > 0 && tempo < 15;
        if (_tempoSelezionato == '15-30 min') return tempo >= 15 && tempo <= 30;
        if (_tempoSelezionato == '> 30 min') return tempo > 30;
        
        return true; // Per fallback mostriamo la ricetta
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ricette', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RicetteModificaView()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra di Ricerca e Filtro Categoria
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: (valore) {
                      setState(() {
                        _queryRicerca = valore;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cerca...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _categoriaSelezionata,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    items: ['Tutte', ...Ricette.categorie].map((String cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (nuovoValore) {
                      setState(() {
                        _categoriaSelezionata = nuovoValore!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Filtri avanzati
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Filtro Difficoltà
                DropdownButton<int?>(
                  value: _difficoltaSelezionata,
                  hint: const Text('Difficoltà'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tutte le difficoltà')),
                    ...List.generate(5, (index) => DropdownMenuItem(
                      value: index + 1, 
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Centra le fiammelle all'interno della riga
                        children: List.generate(index + 1, (_) => const Icon(Icons.local_fire_department, color: Colors.orange, size: 16))
                      )
                    )),
                  ],
                  onChanged: (val) => setState(() => _difficoltaSelezionata = val),
                ),
                const SizedBox(width: 16),
                // Filtro Tempo
                DropdownButton<String>(
                  value: _tempoSelezionato,
                  hint: const Text('Tempo'),
                  items: ['Tutti', '< 15 min', '15-30 min', '> 30 min'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _tempoSelezionato = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          
          // Lista delle Ricette
          Expanded(
            child: ricetteFiltrate.isEmpty
                ? const Center(child: Text('Nessuna ricetta trovata.')) // Messaggio mostrato se i filtri escludono tutto
                : ListView.builder(
                    itemCount: ricetteFiltrate.length, // Definisce quante righe generare dinamicamente
                    itemBuilder: (context, index) {
                      final ricetta = ricetteFiltrate[index]; // Estraggo la ricetta specifica per questa riga
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RicetteDettaglioView(ricetta: ricetta),
                              ),
                            );
                          },
                          leading: Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.restaurant, color: Colors.grey),
                          ),
                          title: Row(
                            children: [
                              Expanded(child: Text(ricetta.titolo, style: const TextStyle(fontWeight: FontWeight.bold))),
                              // Se è una ricetta di sistema, mostriamo un piccolo badge "Predefinita"
                              if (ricetta.isPredefinita)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                                  child: Text('⭐ Predefinita', style: TextStyle(fontSize: 10, color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            ricetta.preparazione,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  ricetta.categoria,
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  // Navighiamo alla schermata di modifica solo se cliccano l'opzione
                                  if (value == 'modifica') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RicetteModificaView(ricetta: ricetta),
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem(
                                    value: 'modifica',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Modifica'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
