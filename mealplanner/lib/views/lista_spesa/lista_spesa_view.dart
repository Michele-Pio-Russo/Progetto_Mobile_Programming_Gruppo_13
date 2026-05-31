import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../viewmodels/lista_spesa_viewmodel.dart';
import '../../viewmodels/piano_pasti_viewmodel.dart';
import '../../viewmodels/ricette_viewmodel.dart';
import '../../viewmodels/dispensa_viewmodel.dart';
import 'lista_spesa_aggiunta_view.dart';

// Usiamo uno StatefulWidget perché dobbiamo tenere in memoria la data che l'utente seleziona dal calendario
class ListaSpesaView extends StatefulWidget {
  const ListaSpesaView({super.key});

  @override
  State<ListaSpesaView> createState() => _ListaSpesaViewState();
}

class _ListaSpesaViewState extends State<ListaSpesaView> {
  late DateTime _dataSelezionata;

  @override
  void initState() {
    super.initState();
    // Prepariamo la formattazione della data in italiano 
    initializeDateFormatting('it_IT', null);
    _dataSelezionata = DateTime.now();
  }

  // Mostra un popup di sicurezza prima di cancellare tutti gli articoli già messi nel carrello
  void _mostraDialogConferma(
    BuildContext context,
    ListaSpesaViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma rimozione'),
          content: const Text(
            'Vuoi davvero rimuovere tutti gli articoli marcati come comprati?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annulla',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                viewModel.rimuoviProdottiComprati();
                Navigator.pop(context);
              },
              child: const Text('Rimuovi', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Gestisce il processo di lettura delle ricette del giorno e aggiunta degli ingredienti mancanti alla lista
  void _mostraDialogConfermaGenerazione(BuildContext context) {
    final giorniSettimana = [
      'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì', 'Venerdì', 'Sabato', 'Domenica',
    ];
    final giornoNome = giorniSettimana[_dataSelezionata.weekday - 1];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Genera da Piano Pasti'),
          content: Text(
            'Vuoi generare gli articoli mancanti confrontando le ricette di $giornoNome con la tua dispensa?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annulla',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                // Recuperiamo i dati dai ViewModel
                // Usiamo listen: false perché siamo dentro a un'azione (il click di un bottone)
                // e stiamo solo eseguendo un calcolo, non dobbiamo aggiornare la grafica in questo esatto punto.
                final pianoPastiVM = Provider.of<PianoPastiViewModel>(context, listen: false);
                final ricetteVM = Provider.of<RicetteViewModel>(context, listen: false);
                final dispensaVM = Provider.of<GestoreDispensa>(context, listen: false);
                final listaSpesaVM = Provider.of<ListaSpesaViewModel>(context, listen: false);

                // Isoliamo solo i pasti che l'utente ha pianificato per il giorno che sta visualizzando
                final pastiOggi = pianoPastiVM.pasti
                    .where((p) => p.giorno == giornoNome)
                    .toList();

                listaSpesaVM.generaDaPianoPasti(
                  pastiOggi,
                  ricetteVM,
                  dispensaVM.articoli,
                );

                Navigator.pop(context);

                // Mostriamo un piccolo banner in basso per confermare all'utente che l'operazione è andata a buon fine
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Lista aggiornata con gli ingredienti di $giornoNome mancanti!',
                    ),
                  ),
                );
              },
              child: const Text(
                'Genera',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lista della Spesa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              DateFormat('EEEE d MMMM yyyy', 'it_IT').format(_dataSelezionata),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Colors.black),
            onPressed: () async {
              // Apre il calendario di sistema per far scegliere una data
              DateTime? scelta = await showDatePicker(
                context: context,
                initialDate: _dataSelezionata,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (scelta != null) {
                setState(() {
                  _dataSelezionata = scelta;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.bolt, color: Colors.black),
            onPressed: () => _mostraDialogConfermaGenerazione(context),
          ),
          // Usiamo un Consumer per il bottone del cestino: vogliamo che appaia solo se c'è almeno un prodotto già spuntato, altrimenti lo nascondiamo
          Consumer<ListaSpesaViewModel>(
            builder: (context, viewModel, child) {
              final haProdottiComprati = viewModel.prodotti.any((p) => p.comprato);
              if (!haProdottiComprati) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.black),
                onPressed: () => _mostraDialogConferma(context, viewModel),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SchermataAggiuntaSpesa(),
            ),
          );
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        shape: const CircleBorder(side: BorderSide(color: Colors.white30)),
        child: const Icon(Icons.add, size: 28),
      ),
      // Questo Consumer ascolta ListaSpesaViewModel e ridisegna solo il corpo della pagina quando i prodotti cambiano
      body: Consumer<ListaSpesaViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.prodotti.isEmpty) {
            return const Center(
              child: Text(
                'La lista della spesa è vuota.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.prodotti.length,
            itemBuilder: (context, index) {
              final prodotto = viewModel.prodotti[index];

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  leading: Checkbox(
                    value: prodotto.comprato,
                    activeColor: Colors.black,
                    onChanged: (bool? valore) {
                      viewModel.toggleComprato(prodotto.id);
                    },
                  ),
                  title: Text(
                    prodotto.nome,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      // Sbarriamo il testo per dare un effetto visivo da lista cartacea spuntata
                      decoration: prodotto.comprato
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: prodotto.comprato ? Colors.grey : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    prodotto.quantita,
                    style: TextStyle(
                      color: prodotto.comprato ? Colors.grey : Colors.black87,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                        onPressed: () {
                          // Passiamo l'oggetto prodotto intero alla schermata, in questo modo i campi di testo saranno già precompilati con i dati vecchi da modificare
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SchermataAggiuntaSpesa(prodotto: prodotto),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          viewModel.rimuoviProdotto(prodotto.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}