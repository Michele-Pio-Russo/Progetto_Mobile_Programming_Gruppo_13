import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/piano_pasti_viewmodel.dart';
import '../../models/piano_pasti_model.dart'; // Assicurati che questo nome file sia corretto!

class PianoPastiView extends StatelessWidget { 
  const PianoPastiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sfondo bianco come nel wireframe
      
      // BARRA SUPERIORE
      appBar: AppBar( 
        backgroundColor: Colors.white,
        elevation: 0, // Rimuove l'ombra sotto la barra per un look più pulito
        title: const Text('Piano pasti', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: false, // Nel wireframe il titolo sembra spostato a sinistra (o centrato, dipende dal telefono)
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [

          // L'icona del calendario in alto a destra
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {
            },
          ),
        ],
      ),
      
      // IL PULSANTE (+)
      floatingActionButton: FloatingActionButton(
        onPressed: () {        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2, // Ombra
        shape: CircleBorder(side: BorderSide(color: Colors.grey.shade300)), // Bordo grigio
        child: const Icon(Icons.add, size: 28),
      ),

      // BODY
      body: Consumer<PianoPastiViewModel>( 
        builder: (context, viewModel, child) { 
          
          // Usiamo una column per impilare il selettore della settimana e la lista dei giorni
          return Column(
            children: [
              
              // Selettore settimana
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spinge frecce ai lati e testo al centro
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                    const Text('20 - 26 Maggio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
                  ],
                ),
              ),

              // LISTA  DEI GIORNI
              // Expanded serve a far prendere alla lista tutto lo spazio rimanente nello schermo
              Expanded(
                child: ListView.builder(
                  itemCount: 7, // 7 giorni della settimana
                  itemBuilder: (context, index) {
                    
                    // Prendiamo i giorni dal model PianoPasti (la lista statica)
                    String giornoCorrente = PianoPasti.giorni[index];

                    // Prendiamo i dati dal viewmodel e filtriamo solo quelli del giorno corrente
                    var pastiDelGiorno = viewModel.pasti.where((p) => p.giorno == giornoCorrente).toList();

                    // Disegniamo la Card (la scheda col bordo grigio) per questo giorno
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 0, // Nessuna ombra pesante
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300, width: 1), // Bordo sottile grigio
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            // Intestazione Card: Giorno e i 3 puntini
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(giornoCorrente, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const Icon(Icons.more_vert, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 16), // Spazio vuoto

                            // Lista dei 3 pasti (Colazione, Pranzo, Cena)
                            ...['Colazione', 'Pranzo', 'Cena'].map((tipologia) {
                              
                              // Cerchiamo il pasto specifico. Fallback di sicurezza in caso mancasse
                              var pasto = pastiDelGiorno.firstWhere(
                                (p) => p.tipologia == tipologia,
                                orElse: () => PianoPasti(id: '', giorno: giornoCorrente, tipologia: tipologia, nomeRicetta: '-', idRicetta: '-') // Assicurati che i parametri del costruttore siano giusti!
                              );

                              // Disegniamo la riga del singolo pasto
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0), // Spazio tra un pasto e l'altro
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // A sinistra: Tipologia (es. "Colazione") con larghezza fissa per allineare tutto
                                    SizedBox(
                                      width: 90, 
                                      child: Text(
                                        tipologia, 
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)
                                      ),
                                    ),
                                    
                                    // A destra: Il nome della ricetta
                                    Expanded(
                                      child: Text(
                                        pasto.nomeRicetta,
                                        style: TextStyle(
                                          // Se la ricetta è "-" (vuota), la scriviamo in grigio chiaro, altrimenti in nero
                                          color: pasto.nomeRicetta == '-' ? Colors.grey : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }), // Fine mappa pasti
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