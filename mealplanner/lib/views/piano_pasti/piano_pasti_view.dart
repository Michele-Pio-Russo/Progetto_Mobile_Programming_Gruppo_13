import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/piano_pasti_viewmodel.dart';
import '../../models/piano_pasti_model.dart';
import 'piano_pasti_modifica_view.dart';

import '../ricette/ricette_dettaglio_view.dart'; // <-- Modifica questo percorso in base al tuo progetto

// IMPORTA IL MODELLO RICETTE (serve se usi l'opzione Mock o se devi tipizzare la ricerca)
import '../../models/ricette_model.dart';

// IMPORTA IL VIEWMODEL DELLE RICETTE (se ne hai uno per cercare la ricetta tramite ID)
// import '../../viewmodels/ricette_viewmodel.dart';

class PianoPastiView extends StatelessWidget {
  const PianoPastiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Piano pasti',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<PianoPastiViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {},
                    ),
                    const Text(
                      '20 - 26 Maggio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    String giornoCorrente = PianoPasti.giorni[index];
                    var pastiDelGiorno = viewModel.pasti
                        .where((p) => p.giorno == giornoCorrente)
                        .toList();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  giornoCorrente,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.black54,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SchermataModificaPianoPasti(
                                                  pasto: PianoPasti(
                                                    id: '',
                                                    giorno: giornoCorrente,
                                                    tipologia: '',
                                                    nomeRicetta: '-',
                                                    idRicetta: '-',
                                                  ),
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          builder: (BuildContext context) {
                                            return SafeArea(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16.0,
                                                    ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 16.0,
                                                          ),
                                                      child: Text(
                                                        'Modifica pasti di $giornoCorrente',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    ...PianoPasti.tipologie.map((
                                                      tipologia,
                                                    ) {
                                                      var pastoDaModificare =
                                                          pastiDelGiorno.firstWhere(
                                                            (p) =>
                                                                p.tipologia ==
                                                                tipologia,
                                                            orElse: () =>
                                                                PianoPasti(
                                                                  id: '',
                                                                  giorno:
                                                                      giornoCorrente,
                                                                  tipologia:
                                                                      tipologia,
                                                                  nomeRicetta:
                                                                      '-',
                                                                  idRicetta:
                                                                      '-',
                                                                ),
                                                          );

                                                      return ListTile(
                                                        leading: const Icon(
                                                          Icons.edit,
                                                          color: Colors.grey,
                                                        ),
                                                        title: Text(
                                                          tipologia,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        subtitle: Text(
                                                          pastoDaModificare
                                                                      .nomeRicetta ==
                                                                  '-'
                                                              ? 'Nessuna ricetta'
                                                              : pastoDaModificare
                                                                    .nomeRicetta,
                                                        ),
                                                        onTap: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SchermataModificaPianoPasti(
                                                                    pasto:
                                                                        pastoDaModificare,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...PianoPasti.tipologie.map((tipologia) {
                              var pasto = pastiDelGiorno.firstWhere(
                                (p) => p.tipologia == tipologia,
                                orElse: () => PianoPasti(
                                  id: '',
                                  giorno: giornoCorrente,
                                  tipologia: tipologia,
                                  nomeRicetta: '-',
                                  idRicetta: '-',
                                ),
                              );

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        tipologia,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        pasto.nomeRicetta,
                                        style: TextStyle(
                                          color: pasto.nomeRicetta == '-'
                                              ? Colors.grey
                                              : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    // NUOVA LOGICA COLLEGAMENTO OCCHIO -> DETTAGLIO RICETTA
                                    if (pasto.nomeRicetta != '-')
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RicetteDettaglioView(
                                                ricetta: Ricette(
                                                  id: pasto.idRicetta,
                                                  titolo: pasto.nomeRicetta,
                                                  categoria: 'Piano Pasti',
                                                  tempoPreparazione:
                                                      '25', // Modificato da int a String come da modello
                                                  difficolta: 2,
                                                  quantita: 'Per 2 persone',
                                                  ingredienti: [],
                                                  preparazione:
                                                      'Procedimento caricato dal piano pasti...',
                                                  note:
                                                      'Nessuna nota temporanea.',
                                                  isPredefinita:
                                                      false, // Aggiunto perché obbligatorio nel costruttore
                                                ),
                                              ),
                                            ),
                                          );
                                          // */
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.visibility_outlined,
                                            size: 20,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
