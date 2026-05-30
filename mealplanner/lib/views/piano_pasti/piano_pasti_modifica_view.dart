import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/piano_pasti_viewmodel.dart';
import '../../viewmodels/ricette_viewmodel.dart';
import '../../models/piano_pasti_model.dart';
import '../../models/ricette_model.dart';

class SchermataModificaPianoPasti extends StatefulWidget {
  final PianoPasti? pasto;

  const SchermataModificaPianoPasti({super.key, this.pasto});

  @override
  State<SchermataModificaPianoPasti> createState() =>
      _SchermataModificaPianoPastiState();
}

class _SchermataModificaPianoPastiState
    extends State<SchermataModificaPianoPasti> {
  String? _giornoSelezionato;
  String? _tipologiaSelezionata;
  String? _idRicettaSelezionata;

  @override
  void initState() {
    super.initState();
    if (widget.pasto != null) {
      _giornoSelezionato = widget.pasto!.giorno.isNotEmpty
          ? widget.pasto!.giorno
          : null;
      
      _tipologiaSelezionata = widget.pasto!.tipologia.isNotEmpty
          ? widget.pasto!.tipologia
          : null;

      if (widget.pasto!.idRicetta != '-') {
        _idRicettaSelezionata = widget.pasto!.idRicetta;
      }
    }
  }

  void _mostraConfermaEliminazione(
    BuildContext context,
    PianoPastiViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Rimuovere pasto?'),
          content: Text(
            'Sei sicuro di voler rimuovere la ricetta dal ${widget.pasto!.tipologia} di ${widget.pasto!.giorno}?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Annulla',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                String idCasella =
                    '${widget.pasto!.giorno.substring(0, 3).toLowerCase()}_${widget.pasto!.tipologia.substring(0, 3).toLowerCase()}';

                viewModel.salvaPasto(
                  idCasella,
                  widget.pasto!.giorno,
                  widget.pasto!.tipologia,
                  '-',
                  '-',
                );

                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text(
                'Elimina',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PianoPastiViewModel>(context, listen: false);
    final ricetteViewModel = Provider.of<RicetteViewModel>(context);

    final List<Ricette> ricetteDisponibili = ricetteViewModel.ricette;

    if (_idRicettaSelezionata != null && 
        _idRicettaSelezionata != '-' && 
        !ricetteDisponibili.any((r) => r.id == _idRicettaSelezionata)) {
      _idRicettaSelezionata = null;
    }

    final bool isAggiunta =
        widget.pasto == null || widget.pasto!.tipologia.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isAggiunta ? 'Aggiungi pasto' : 'Modifica ricetta',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAggiunta) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Aggiunta pasto per: $_giornoSelezionato',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tipologia pasto',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _tipologiaSelezionata,
                hint: const Text('Seleziona la tipologia'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: PianoPasti.tipologie.map((String tipologia) {
                  return DropdownMenuItem<String>(
                    value: tipologia,
                    child: Text(tipologia),
                  );
                }).toList(),
                onChanged: (nuovaTipologia) {
                  setState(() {
                    _tipologiaSelezionata = nuovaTipologia;
                  });
                },
              ),
              const SizedBox(height: 20),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Stai modificando: ${widget.pasto!.tipologia} di ${widget.pasto!.giorno}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],

            const Text(
              'Seleziona una ricetta dal ricettario',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _idRicettaSelezionata,
              hint: const Text('Tocca per scegliere una ricetta...'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                prefixIcon: const Icon(Icons.restaurant_menu),
              ),
              items: ricetteDisponibili.map((Ricette ricetta) {
                return DropdownMenuItem<String>(
                  value: ricetta.id,
                  child: Text(ricetta.titolo),
                );
              }).toList(),
              onChanged: (nuovoId) {
                setState(() {
                  _idRicettaSelezionata = nuovoId;
                });
              },
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_giornoSelezionato == null ||
                      _tipologiaSelezionata == null) {
                    return;
                  }

                  String nomeRicettaInserita = '-';
                  String idRicettaInserita = '-';

                  if (_idRicettaSelezionata != null) {
                    final ricettaScelta = ricetteViewModel.ottieniRicettaPerId(_idRicettaSelezionata!);
                    if (ricettaScelta != null) {
                      nomeRicettaInserita = ricettaScelta.titolo;
                      idRicettaInserita = ricettaScelta.id;
                    }
                  }

                  String idCasella =
                      '${_giornoSelezionato!.substring(0, 3).toLowerCase()}_${_tipologiaSelezionata!.substring(0, 3).toLowerCase()}';

                  viewModel.salvaPasto(
                    idCasella,
                    _giornoSelezionato!,
                    _tipologiaSelezionata!,
                    nomeRicettaInserita,
                    idRicettaInserita,
                  );

                  Navigator.pop(context);
                },
                child: Text(
                  isAggiunta ? 'Salva nel piano' : 'Salva modifiche',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (!isAggiunta && widget.pasto!.nomeRicetta != '-')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(
                    'Rimuovi pasto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _mostraConfermaEliminazione(context, viewModel);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}