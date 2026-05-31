import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/piano_pasti_viewmodel.dart';
import '../../viewmodels/ricette_viewmodel.dart';
import '../../models/piano_pasti_model.dart';
import '../../models/ricette_model.dart';
import '../../theme/style.dart'; // Mantieni il tuo import di stile


// StatefulWidget è necessario perché questa schermata gestisce uno stato locale cioè 
// le selezioni dell'utente nei menu a tendina (giorno, tipologia, ricetta) cambiano nel tempo
// e l'interfaccia si deve aggiornare per mostrarle
class SchermataModificaPianoPasti extends StatefulWidget {
  final PianoPasti? pasto;

  const SchermataModificaPianoPasti({super.key, this.pasto});

  @override
  State<SchermataModificaPianoPasti> createState() =>
      _SchermataModificaPianoPastiState();
}

class _SchermataModificaPianoPastiState
    extends State<SchermataModificaPianoPasti> {
  
  // Variabili di stato interne per tenere traccia delle scelte correnti dell'utente
  // Sono nullable (?) perché all'inizio potrebbero non essere state ancora scelte
  String? _giornoSelezionato;
  String? _tipologiaSelezionata;
  String? _idRicettaSelezionata;

  // initState() viene chiamato una sola volta quando la schermata viene creata.
  @override
  void initState() {
    super.initState();
    
    if (widget.pasto != null) {
      // Controlliamo che il giorno non sia una stringa vuota prima di assegnarlo, 
      _giornoSelezionato = widget.pasto!.giorno.isNotEmpty
          ? widget.pasto!.giorno
          : null;
      
      _tipologiaSelezionata = widget.pasto!.tipologia.isNotEmpty
          ? widget.pasto!.tipologia
          : null;

      // Ignoriamo se è vuota
      if (widget.pasto!.idRicetta != '-') {
        _idRicettaSelezionata = widget.pasto!.idRicetta;
      }
    }
  }

  // Una funzione separata per gestire il popup di conferma eliminazione. 
  void _mostraConfermaEliminazione(
    BuildContext context,
    PianoPastiViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Rimuovere pasto?'),
          // Usiamo l'interpolazione delle stringhe (${...}) per rendere il messaggio dinamico e chiaro per l'utente.
          content: Text(
            'Sei sicuro di voler rimuovere la ricetta dal ${widget.pasto!.tipologia} di ${widget.pasto!.giorno}?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyle.raggioCard),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), // Chiude solo il popup (ctx)
              child: const Text(
                'Annulla',
                style: TextStyle(color: AppStyle.coloreTestoSecondario),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyle.coloreErrore,
                foregroundColor: AppStyle.coloreBianco,
              ),
              onPressed: () {
                // Usiamo l'ID esatto del pasto passato dalla schermata precedente
                String idCasella = widget.pasto!.id;
                 
                // Sovrascriviamo la riga con '-'. 
                viewModel.salvaPasto(
                  idCasella,
                  widget.pasto!.giorno,
                  widget.pasto!.tipologia,
                  '-',
                  '-',
                );

                Navigator.pop(ctx);     // Chiude il popup di conferma
                Navigator.pop(context); // Chiude la schermata di modifica e torna al calendario
              },
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );
  }

  // Metodo per costruire l'interfaccia grafica della schermata
  @override
  Widget build(BuildContext context) {
    // Recuperiamo i ViewModel forniti dal Provider.
    final viewModel = Provider.of<PianoPastiViewModel>(context, listen: false);
    
    // listen è true (di default) -> Ci serve la lista aggiornata delle ricette per il menu a tendina.
    final ricetteViewModel = Provider.of<RicetteViewModel>(context);

    final List<Ricette> ricetteDisponibili = ricetteViewModel.ricette;

    // Se stavamo modificando un pasto che aveva una ricetta, ma nel frattempo quella ricetta 
    // è stata cancellata dal database globale, l'ID non sarà più valido
    if (_idRicettaSelezionata != null && 
        _idRicettaSelezionata != '-' && 
        !ricetteDisponibili.any((r) => r.id == _idRicettaSelezionata)) {
      _idRicettaSelezionata = null;
    }

    // Variabile booleana calcolata per capire in che modalità siamo
    final bool isAggiunta =
        widget.pasto == null || widget.pasto!.tipologia.isEmpty;

    return Scaffold(
      appBar: AppBar(
        // Titolo in base alla modalità
        title: Text(
          isAggiunta ? 'Aggiungi pasto' : 'Modifica ricetta',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Invece di avere due blocchi di codice completamente separati, inseriamo dinamicamente 
            // una lista di widget direttamente dentro la colonna usando ...[ ]
            if (isAggiunta) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppStyle.coloreTestoSecondario.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
                  border: Border.all(color: AppStyle.coloreTestoSecondario.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppStyle.coloreTestoSecondario, size: 22),
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
              
              // Menu a tendina per scegliere se è Colazione, Pranzo, ecc.
              DropdownButtonFormField<String>(
                initialValue: _tipologiaSelezionata,
                hint: const Text('Seleziona la tipologia'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                // Mappa la lista statica PianoPasti.tipologie in elementi cliccabili del menu
                items: PianoPasti.tipologie.map((String tipologia) {
                  return DropdownMenuItem<String>(
                    value: tipologia,
                    child: Text(tipologia),
                  );
                }).toList(),
                // Quando l'utente seleziona una voce, aggiorniamo lo stato interno
                onChanged: (nuovaTipologia) {
                  setState(() {
                    _tipologiaSelezionata = nuovaTipologia;
                  });
                },
              ),
              const SizedBox(height: 20),
            ] else ...[
              // Mostra un riquadro fisso con le informazioni del pasto che si sta modificando,
              // impedendo di cambiare giorno o tipologia
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppStyle.coloreTestoSecondario.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
                  border: Border.all(color: AppStyle.coloreTestoSecondario.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppStyle.coloreTestoSecondario),
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
            
            // Menu a tendina per scegliere la ricetta
            DropdownButtonFormField<String>(
              initialValue: _idRicettaSelezionata,
              hint: const Text('Tocca per scegliere una ricetta...'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                prefixIcon: const Icon(Icons.restaurant_menu_outlined, color: AppStyle.coloreTestoSecondario),
              ),
              // Popoliamo il menu attingendo direttamente dalla lista fornita dal RicetteViewModel
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

            // Bottone di salvataggio
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_giornoSelezionato == null ||
                      _tipologiaSelezionata == null) {
                    return; 
                  }

                  // Impostiamo valori di default (il trattino) se l'utente non seleziona nulla
                  String nomeRicettaInserita = '-';
                  String idRicettaInserita = '-';

                  // Se ha scelto una ricetta, recuperiamo il nome esatto usando il ViewModel
                  // Salviamo sia l'ID (per ritrovarla) che il Nome (per mostrarlo velocemente nel calendario)
                  if (_idRicettaSelezionata != null) {
                    final ricettaScelta = ricetteViewModel.ottieniRicettaPerId(_idRicettaSelezionata!);
                    if (ricettaScelta != null) {
                      nomeRicettaInserita = ricettaScelta.titolo;
                      idRicettaInserita = ricettaScelta.id;
                    }
                  }

                  // Generiamo la chiave univoca: se stiamo aggiungendo, uniamo la data (id base) alla tipologia
                  // altrimenti usiamo l'id esatto già esistente
                  String idCasella = isAggiunta 
                      ? '${widget.pasto!.id}_$_tipologiaSelezionata' 
                      : widget.pasto!.id;

                  // Salviamo
                  viewModel.salvaPasto(
                    idCasella,
                    _giornoSelezionato!,
                    _tipologiaSelezionata!,
                    nomeRicettaInserita,
                    idRicettaInserita,
                  );

                  // Chiudiamo la schermata e torniamo indietro
                  Navigator.pop(context);
                },
                child: Text(
                  isAggiunta ? 'Salva nel piano' : 'Salva modifiche',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bottone di eliminazione
            // Mostrato solo  se non stiamo aggiungendo un pasto nuovo
            // E solo se il pasto attualmente salvato ha una ricetta vera (non il trattino)
            if (!isAggiunta && widget.pasto!.nomeRicetta != '-')
              SizedBox(
                width: double.infinity,
                height: 50,
                // Correzione: reinseriti i parametri 'icon' e 'label' obbligatori per TextButton.icon
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppStyle.coloreErrore,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Rimuovi pasto'),
                  onPressed: () {
                    // Quando l'utente clicca su "Elimina", mostriamo un popup di conferma 
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