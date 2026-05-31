import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dispensa_viewmodel.dart';
import '../../models/dispensa_model.dart';
import 'dispensa_modifica_view.dart'; 
import '../../theme/style.dart';


class SchermataDispensa extends StatefulWidget {
  const SchermataDispensa({super.key});

  @override
  State<SchermataDispensa> createState() => _SchermataDispensaState();
}

class _SchermataDispensaState extends State<SchermataDispensa> {
  String filtroAttuale = 'Tutti'; // Gestisce i tre bottoni
  String _categoriaSelezionata = 'Tutte'; // 'Tutte' è il valore di default

  @override
  Widget build(BuildContext context) {
    final gestore = Provider.of<GestoreDispensa>(context);
    
    // Logica per filtrare gli articoli in base al bottone selezionato
    List<Dispensa> articoliFiltrati = gestore.articoli;
    if (filtroAttuale == 'In scadenza') {
      articoliFiltrati = gestore.articoli.where((a) => a.scadenza != null && a.statoCritico && a.quantita > 0).toList();
    } else if (filtroAttuale == 'In esaurimento') {
      articoliFiltrati = gestore.articoli.where((a) => a.quantita <= 0).toList();
    }
    if (_categoriaSelezionata != 'Tutte') {
      articoliFiltrati = articoliFiltrati.where((a) => a.categoria == _categoriaSelezionata).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispensa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // Naviga alla schermata di aggiunta
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SchermataModificaProdotto()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra di Ricerca per i prodotti della dispensa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cerca...',
                      prefixIcon: const Icon(Icons.search_outlined, color: AppStyle.coloreTestoSecondario),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
                        borderSide: BorderSide(color: AppStyle.coloreTestoSecondario.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
                        borderSide: BorderSide(color: AppStyle.coloreTestoSecondario.withOpacity(0.2)),
                      ),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
                        borderSide: BorderSide(color: AppStyle.coloreTestoSecondario.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
                        borderSide: BorderSide(color: AppStyle.coloreTestoSecondario.withOpacity(0.2)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    items: ['Tutte', ...Dispensa.categorie].map((String cat) {
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

          // I tre Bottoni di Filtro ("Tutti", "In scadenza", "In esaurimento")
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _costruisciBottoneFiltro('Tutti'),
                _costruisciBottoneFiltro('In scadenza'),
                _costruisciBottoneFiltro('In esaurimento'),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Lista dei Prodotti
          Expanded(
            child: articoliFiltrati.isEmpty
                ? const Center(child: Text('Nessun prodotto trovato.'))
                : ListView.builder(
                    itemCount: articoliFiltrati.length,
                    itemBuilder: (context, index) {
                      final articolo = articoliFiltrati[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppStyle.coloreBianco,
                          borderRadius: BorderRadius.circular(AppStyle.raggioCard),
                          boxShadow: AppStyle.ombraNuvola,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyle.raggioCard)),
                          onTap: () {
                            // Cliccando sul prodotto si apre la modifica
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SchermataModificaProdotto(articolo: articolo),
                              ),
                            );
                          },
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppStyle.coloreTestoSecondario.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.fastfood_outlined, color: AppStyle.coloreTestoSecondario),
                          ),
                          title: Text(articolo.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${articolo.quantita} ${articolo.unita}', style: const TextStyle(color: AppStyle.coloreTestoSecondario)),
                              if (articolo.scadenza != null)
                                Text(
                                  'Scade: ${articolo.scadenza!.day}/${articolo.scadenza!.month}/${articolo.scadenza!.year}',
                                  style: const TextStyle(fontSize: 12, color: AppStyle.coloreTestoSecondario),
                                ),
                            ],
                          ),
                          // Badge a destra (In scadenza / In esaurimento / OK)
                          trailing: _costruisciBadgeStato(articolo),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget di aiuto per creare i bottoni di filtro in alto
  Widget _costruisciBottoneFiltro(String testo) {
    final selezionato = filtroAttuale == testo;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selezionato ? AppStyle.colorePrimario : AppStyle.coloreBianco,
        foregroundColor: selezionato ? AppStyle.coloreBianco : AppStyle.coloreTestoPrincipale,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyle.raggioBottoni)),
        side: BorderSide(
          color: selezionato ? Colors.transparent : AppStyle.coloreTestoSecondario.withOpacity(0.2),
        ),
      ),
      onPressed: () {
        setState(() {
          filtroAttuale = testo;
        });
      },
      child: Text(testo, style: const TextStyle(fontSize: 12)),
    );
  }

  // Widget per creare le etichette arrotondate
  Widget _costruisciBadgeStato(Dispensa articolo) {
    String testo = 'OK';
    Color coloreSfondo = AppStyle.coloreTestoSecondario.withOpacity(0.1);
    Color coloreTesto = AppStyle.coloreTestoSecondario;

    if (articolo.quantita <= 0) {
      testo = 'In esaurimento';
      coloreSfondo = AppStyle.coloreErrore.withOpacity(0.1);
      coloreTesto = AppStyle.coloreErrore;
    } else if (articolo.statoCritico) {
      testo = 'In scadenza';
      coloreSfondo = Colors.orange.withOpacity(0.1);
      coloreTesto = Colors.orange.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: coloreSfondo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(testo, style: TextStyle(color: coloreTesto, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}