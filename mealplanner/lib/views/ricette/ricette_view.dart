import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/ricette_viewmodel.dart';
import '../../models/ricette_model.dart';
import 'ricette_modifica_view.dart';
import 'ricette_dettaglio_view.dart';
import '../../theme/style.dart';

/// Schermata principale del Ricettario.
/// Permette all'utente di visualizzare l'elenco di tutte le ricette,
/// filtrarle per testo, categoria, difficoltà e tempo di preparazione,
/// e navigare verso la schermata di dettaglio o di aggiunta/modifica.
class RicetteView extends StatefulWidget {
  // Costruttore della schermata delle ricette
  const RicetteView({super.key});

  @override
  State<RicetteView> createState() => _RicetteViewState();
}

// Classe per la gestione dello stato della schermata delle ricette
class _RicetteViewState extends State<RicetteView> {
  /// Categoria correntemente selezionata per il filtraggio (es. 'Primi Piatti'). 
  /// 'Tutte' disabilita il filtro.
  String _categoriaSelezionata = 'Tutte'; 
  
  /// Testo digitato dall'utente nella barra di ricerca per trovare ricette per titolo.
  String _queryRicerca = ''; 
  
  /// Livello di difficoltà selezionato (da 1 a 5 fiammelle).
  /// Se null, il filtro è disabilitato e mostra tutte le difficoltà.
  int? _difficoltaSelezionata; 
  
  /// Filtro sul tempo stimato di preparazione ('Tutti', '< 15 min', '15-30 min', '> 30 min').
  String _tempoSelezionato = 'Tutti';

  // Disegna l'interfaccia con la barra di ricerca, i filtri e la lista delle ricette
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RicetteViewModel>(context);

    // Applichiamo i filtri in cascata: ogni passaggio riduce ulteriormente la lista.

    // 1. Filtraggio testuale: cerca la query nel titolo delle ricette
    List<Ricette> ricetteFiltrate = viewModel.cercaRicette(_queryRicerca);

    // 2. Filtraggio per Categoria
    if (_categoriaSelezionata != 'Tutte') {
      ricetteFiltrate = ricetteFiltrate
          .where((r) => r.categoria == _categoriaSelezionata)
          .toList();
    }

    // 3. Filtraggio per Difficoltà
    if (_difficoltaSelezionata != null) {
      ricetteFiltrate = ricetteFiltrate
          .where((r) => r.difficolta == _difficoltaSelezionata)
          .toList();
    }

    // 4. Filtraggio per Tempo di Preparazione (richiede il parsing della stringa in int)
    if (_tempoSelezionato != 'Tutti') {
      ricetteFiltrate = ricetteFiltrate.where((r) {
        // Il tempo è salvato testualmente (es. "20"), quindi cerchiamo di convertirlo in un numero
        int tempo = int.tryParse(r.tempoPreparazione) ?? 0;

        // Confrontiamo il tempo con le fasce selezionate
        if (_tempoSelezionato == '< 15 min') return tempo > 0 && tempo < 15;
        if (_tempoSelezionato == '15-30 min') return tempo >= 15 && tempo <= 30;
        if (_tempoSelezionato == '> 30 min') return tempo > 30;

        return true; // Se nessuna regola corrisponde, manteniamo la ricetta per sicurezza
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ricette'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RicetteModificaView(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra di Ricerca e Filtro Categoria
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
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
                      prefixIcon: const Icon(
                        Icons.search_outlined,
                        color: AppStyle.coloreTestoSecondario,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppStyle.raggioBottoni,
                        ),
                        borderSide: BorderSide(
                          color: AppStyle.coloreTestoSecondario.withValues(alpha: 
                            0.2,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppStyle.raggioBottoni,
                        ),
                        borderSide: BorderSide(
                          color: AppStyle.coloreTestoSecondario.withValues(alpha: 
                            0.2,
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    isExpanded:
                        true, // <-- AGGIUNTO: Risolve l'overflow tagliando il testo troppo lungo!
                    initialValue: _categoriaSelezionata,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppStyle.raggioBottoni,
                        ),
                        borderSide: BorderSide(
                          color: AppStyle.coloreTestoSecondario.withValues(alpha: 
                            0.2,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppStyle.raggioBottoni,
                        ),
                        borderSide: BorderSide(
                          color: AppStyle.coloreTestoSecondario.withValues(alpha: 
                            0.2,
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
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
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tutte le difficoltà'),
                    ),
                    ...List.generate(
                      5,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centra le fiammelle all'interno della riga
                          children: List.generate(
                            index + 1,
                            (_) => const Icon(
                              Icons.local_fire_department_outlined,
                              color: Colors.orange,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) =>
                      setState(() => _difficoltaSelezionata = val),
                ),
                const SizedBox(width: 16),
                // Filtro Tempo
                DropdownButton<String>(
                  value: _tempoSelezionato,
                  hint: const Text('Tempo'),
                  items: ['Tutti', '< 15 min', '15-30 min', '> 30 min']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
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
                ? const Center(
                    child: Text('Nessuna ricetta trovata.'),
                  ) // Messaggio mostrato se i filtri escludono tutto
                : ListView.builder(
                    itemCount: ricetteFiltrate
                        .length, // Definisce quante righe generare dinamicamente
                    itemBuilder: (context, index) {
                      final ricetta =
                          ricetteFiltrate[index]; // Estraggo la ricetta specifica per questa riga
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppStyle.coloreBianco,
                          borderRadius: BorderRadius.circular(
                            AppStyle.raggioCard,
                          ),
                          boxShadow: AppStyle.ombraNuvola,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppStyle.raggioCard,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RicetteDettaglioView(ricetta: ricetta),
                              ),
                            );
                          },
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppStyle.coloreTestoSecondario.withValues(alpha: 
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.restaurant_outlined,
                              color: AppStyle.coloreTestoSecondario,
                            ),
                          ),
                          title: Text(
                            ricetta.titolo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                ricetta.preparazione,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppStyle.coloreTestoSecondario,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (ricetta.isPredefinita)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '⭐ Predefinita',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppStyle.colorePrimario.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      ricetta.categoria,
                                      style: const TextStyle(
                                        color: AppStyle.colorePrimario,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppStyle.coloreTestoSecondario,
                            ),
                            onPressed: () {
                              // Cliccando la matita navighiamo direttamente alla schermata di modifica
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RicetteModificaView(ricetta: ricetta),
                                ),
                              );
                            },
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
