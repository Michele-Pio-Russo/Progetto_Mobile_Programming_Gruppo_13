import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/piano_pasti_viewmodel.dart';
import '../../models/piano_pasti_model.dart';

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
  String? _ricettaSelezionata;

  final List<String> _ricetteDisponibili = [
    'Spaghetti al pomodoro',
    'Pollo con patate',
    'Insalata mista',
    'Pancake proteici',
    'Tiramisù',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.pasto != null) {
      _giornoSelezionato = widget.pasto!.giorno;
      _tipologiaSelezionata = widget.pasto!.tipologia;
      if (widget.pasto!.nomeRicetta != '-') {
        _ricettaSelezionata = widget.pasto!.nomeRicetta;
        if (!_ricetteDisponibili.contains(_ricettaSelezionata)) {
          _ricetteDisponibili.add(_ricettaSelezionata!);
        }
      }
    }
  }

  void _mostraConfermaEliminazione(BuildContext context, PianoPastiViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Rimuovere pasto?'),
          content: Text('Sei sicuro di voler rimuovere la ricetta dal ${widget.pasto!.tipologia} di ${widget.pasto!.giorno}?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                String idCasella = '${widget.pasto!.giorno.substring(0, 3).toLowerCase()}_${widget.pasto!.tipologia.substring(0, 3).toLowerCase()}';
                
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
              child: const Text('Elimina', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PianoPastiViewModel>(context, listen: false);
    final bool isAggiunta = widget.pasto == null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isAggiunta ? 'Aggiungi pasto' : 'Modifica ricetta',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAggiunta) ...[
              const Text(
                'Giorno della settimana',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _giornoSelezionato,
                hint: const Text('Seleziona il giorno'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: PianoPasti.giorni.map((String giorno) {
                  return DropdownMenuItem<String>(value: giorno, child: Text(giorno));
                }).toList(),
                onChanged: (nuovoGiorno) {
                  setState(() { _giornoSelezionato = nuovoGiorno; });
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Tipologia pasto',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _tipologiaSelezionata,
                hint: const Text('Seleziona la tipologia'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: PianoPasti.tipologie.map((String tipologia) {
                  return DropdownMenuItem<String>(value: tipologia, child: Text(tipologia));
                }).toList(),
                onChanged: (nuovaTipologia) {
                  setState(() { _tipologiaSelezionata = nuovaTipologia; });
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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
              value: _ricettaSelezionata,
              hint: const Text('Tocca per scegliere una ricetta...'),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                prefixIcon: const Icon(Icons.restaurant_menu),
              ),
              items: _ricetteDisponibili.map((String nomeRicetta) {
                return DropdownMenuItem<String>(value: nomeRicetta, child: Text(nomeRicetta));
              }).toList(),
              onChanged: (nuovaScelta) {
                setState(() { _ricettaSelezionata = nuovaScelta; });
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_giornoSelezionato == null || _tipologiaSelezionata == null) return;

                  String nomeRicettaInserita = _ricettaSelezionata ?? '-';
                  String idCasella = '${_giornoSelezionato!.substring(0, 3).toLowerCase()}_${_tipologiaSelezionata!.substring(0, 3).toLowerCase()}';

                  viewModel.salvaPasto(
                    idCasella,
                    _giornoSelezionato!,
                    _tipologiaSelezionata!,
                    nomeRicettaInserita,
                    nomeRicettaInserita == '-' ? '-' : 'id_${nomeRicettaInserita.replaceAll(' ', '_').toLowerCase()}',
                  );

                  Navigator.pop(context);
                },
                child: Text(
                  isAggiunta ? 'Salva nel piano' : 'Salva modifiche',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Rimuovi pasto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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