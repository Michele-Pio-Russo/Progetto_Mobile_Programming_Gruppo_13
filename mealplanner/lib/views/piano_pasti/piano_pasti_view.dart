import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../viewmodels/piano_pasti_viewmodel.dart';
import '../../models/piano_pasti_model.dart';
import 'piano_pasti_modifica_view.dart'; // <-- Assicurati che questo file si chiami così nel tuo progetto!

import '../ricette/ricette_dettaglio_view.dart';
import '../../models/ricette_model.dart';
import '../../theme/style.dart'; // Mantieni il tuo import di stile


class PianoPastiView extends StatefulWidget {
  const PianoPastiView({super.key});

  @override
  State<PianoPastiView> createState() => _PianoPastiViewState();
}

class _PianoPastiViewState extends State<PianoPastiView> {
  late DateTime _inizioSettimana;

  @override
  void initState() {
    super.initState();
    // Inizializza la lingua per le date in modo da mostrare "Lunedì" invece di "Monday"
    initializeDateFormatting('it_IT', null);
    
    DateTime ora = DateTime.now();
    // Calcolo matematico elegante per trovare infallibilmente il Lunedì della settimana in corso.
    _inizioSettimana = ora.subtract(Duration(days: ora.weekday - 1));
    _inizioSettimana = DateTime(_inizioSettimana.year, _inizioSettimana.month, _inizioSettimana.day);
  }

  String _ottieniTestoIntervallo() {
    DateTime fineSettimana = _inizioSettimana.add(const Duration(days: 6));
    if (_inizioSettimana.month == fineSettimana.month) {
      return "${_inizioSettimana.day} - ${DateFormat('d MMMM', 'it_IT').format(fineSettimana)}";
    } else {
      return "${DateFormat('d MMMM', 'it_IT').format(_inizioSettimana)} - ${DateFormat('d MMMM', 'it_IT').format(fineSettimana)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piano pasti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () async {
              DateTime? scelta = await showDatePicker(
                context: context,
                initialDate: _inizioSettimana,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (scelta != null) {
                setState(() {
                  _inizioSettimana = scelta.subtract(Duration(days: scelta.weekday - 1));
                });
              }
            },
          ),
        ],
      ),
      // Il Consumer avvolge l'interfaccia: ottimizza le prestazioni ridisegnando solo questa parte
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
                      onPressed: () {
                        setState(() {
                          _inizioSettimana = _inizioSettimana.subtract(const Duration(days: 7));
                        });
                      },
                    ),
                    Text(
                      _ottieniTestoIntervallo(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _inizioSettimana = _inizioSettimana.add(const Duration(days: 7));
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    String giornoCorrente = PianoPasti.giorni[index];
                    DateTime dataGiorno = _inizioSettimana.add(Duration(days: index));
                    
                    // Creiamo una stringa univoca per la data corrente (es. 2026_5_20)
                    String stringaData = "${dataGiorno.year}_${dataGiorno.month}_${dataGiorno.day}";

                    // Filtriamo solo i pasti che hanno nel loro ID la data esatta di oggi
                    var pastiDelGiorno = viewModel.pasti
                        .where((p) => p.id.startsWith(stringaData))
                        .toList();

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppStyle.coloreBianco,
                        borderRadius: BorderRadius.circular(AppStyle.raggioCard),
                        boxShadow: AppStyle.ombraNuvola,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "$giornoCorrente ${dataGiorno.day}",
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
                                        color: AppStyle.coloreTestoSecondario,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SchermataModificaPianoPasti(
                                              pasto: PianoPasti(
                                                id: stringaData, // Passiamo la data come ID di base
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
                                        color: AppStyle.coloreTestoSecondario,
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: AppStyle.coloreSfondo,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(AppStyle.raggioCard),
                                            ),
                                          ),
                                          builder: (BuildContext context) {
                                            return SafeArea(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 16.0),
                                                      child: Text(
                                                        'Modifica pasti di $giornoCorrente',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    ...PianoPasti.tipologie.map((tipologia) {
                                                      // Usiamo l'ID esatto (Data + Tipologia)
                                                      String idCasella = "${stringaData}_$tipologia";
                                                      var pastoDaModificare = pastiDelGiorno.firstWhere(
                                                        (p) => p.id == idCasella,
                                                        orElse: () => PianoPasti(
                                                          id: idCasella,
                                                          giorno: giornoCorrente,
                                                          tipologia: tipologia,
                                                          nomeRicetta: '-',
                                                          idRicetta: '-',
                                                        ),
                                                      );

                                                      return ListTile(
                                                        leading: const Icon(Icons.edit_outlined, color: AppStyle.coloreTestoSecondario),
                                                        title: Text(
                                                          tipologia,
                                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                                        ),
                                                        subtitle: Text(
                                                          pastoDaModificare.nomeRicetta == '-'
                                                              ? 'Nessuna ricetta'
                                                              : pastoDaModificare.nomeRicetta,
                                                        ),
                                                        onTap: () {
                                                          Navigator.pop(context);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => SchermataModificaPianoPasti(
                                                                pasto: pastoDaModificare,
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
                              String idCasella = "${stringaData}_$tipologia";
                              var pasto = pastiDelGiorno.firstWhere(
                                (p) => p.id == idCasella,
                                orElse: () => PianoPasti(
                                  id: idCasella,
                                  giorno: giornoCorrente,
                                  tipologia: tipologia,
                                  nomeRicetta: '-',
                                  idRicetta: '-',
                                ),
                              );

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                                          color: pasto.nomeRicetta == '-' ? AppStyle.coloreTestoSecondario : AppStyle.coloreTestoPrincipale,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
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
                                                  tempoPreparazione: '25',
                                                  difficolta: 2,
                                                  quantita: 'Per 2 persone',
                                                  ingredienti: [],
                                                  preparazione: 'Procedimento caricato dal piano pasti...',
                                                  note: 'Nessuna nota temporanea.',
                                                  isPredefinita: false,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.visibility_outlined,
                                            size: 20,
                                            color: AppStyle.coloreTestoSecondario,
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