import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../viewmodels/lista_spesa_viewmodel.dart';
import '../../viewmodels/piano_pasti_viewmodel.dart';
import '../../viewmodels/ricette_viewmodel.dart';
import '../../viewmodels/dispensa_viewmodel.dart';
import 'lista_spesa_aggiunta_view.dart';
import '../../theme/style.dart';


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
                style: TextStyle(color: AppStyle.coloreTestoSecondario),
              ),
            ),
            TextButton(
              onPressed: () {
                viewModel.rimuoviProdottiComprati();
                Navigator.pop(context);
              },
              child: const Text('Rimuovi', style: TextStyle(color: AppStyle.coloreErrore)),
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
                style: TextStyle(color: AppStyle.coloreTestoSecondario),
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
                  color: AppStyle.colorePrimario,
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lista della Spesa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('EEEE d MMMM yyyy', 'it_IT').format(_dataSelezionata),
              style: const TextStyle(
                fontSize: 12,
                color: AppStyle.coloreTestoSecondario,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
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
            icon: const Icon(Icons.bolt),
            onPressed: () => _mostraDialogConfermaGenerazione(context),
          ),
          // Usiamo un Consumer per il bottone del cestino: vogliamo che appaia solo se c'è almeno un prodotto già spuntato, altrimenti lo nascondiamo
          Consumer<ListaSpesaViewModel>(
            builder: (context, viewModel, child) {
              final haProdottiComprati = viewModel.prodotti.any((p) => p.comprato);
              if (!haProdottiComprati) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.delete_sweep),
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
        backgroundColor: AppStyle.colorePrimario,
        foregroundColor: AppStyle.coloreBianco,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
      // Questo Consumer ascolta ListaSpesaViewModel e ridisegna solo il corpo della pagina quando i prodotti cambiano
      body: Consumer<ListaSpesaViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.prodotti.isEmpty) {
            return const Center(
              child: Text(
                'La lista della spesa è vuota.',
                style: TextStyle(color: AppStyle.coloreTestoSecondario, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.prodotti.length,
            itemBuilder: (context, index) {
              final prodotto = viewModel.prodotti[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                  color: AppStyle.coloreBianco,
                  borderRadius: BorderRadius.circular(AppStyle.raggioCard),
                  boxShadow: AppStyle.ombraNuvola,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyle.raggioCard),
                  ),
                  leading: Checkbox(
                    value: prodotto.comprato,
                    activeColor: AppStyle.colorePrimario,
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
                      color: prodotto.comprato ? AppStyle.coloreTestoSecondario : AppStyle.coloreTestoPrincipale,
                    ),
                  ),
                  subtitle: Text(
                    prodotto.quantita,
                    style: TextStyle(
                      color: prodotto.comprato ? AppStyle.coloreTestoSecondario : AppStyle.coloreTestoPrincipale,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppStyle.coloreTestoSecondario),
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
                        icon: const Icon(Icons.delete_outline, color: AppStyle.coloreErrore),
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