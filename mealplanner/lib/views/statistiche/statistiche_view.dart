import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../theme/style.dart';
import '../../viewmodels/ricette_viewmodel.dart';
import '../../viewmodels/dispensa_viewmodel.dart';
import '../../viewmodels/piano_pasti_viewmodel.dart';

class StatisticheView extends StatelessWidget {
  const StatisticheView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lettura dei ViewModel necessari tramite Provider
    final ricetteVM = context.watch<RicetteViewModel>();
    final dispensaVM = context.watch<GestoreDispensa>();
    final pianoPastiVM = context.watch<PianoPastiViewModel>();

    // Liste di dati principali estratti dai ViewModel
    final ricette = ricetteVM.ricette;       // Tutte le ricette salvate
    final articoli = dispensaVM.articoli;    // Tutti gli ingredienti presenti in dispensa
    
    // 1. Ricette per categoria e calcolo della categoria più usata
    final catMap = <String, int>{}; // Mappa {NomeCategoria: Conteggio}
    for (final r in ricette) {
      catMap[r.categoria] = (catMap[r.categoria] ?? 0) + 1;
    }
    
    // Ordina per frequenza e prendi la prima
    String categoriaPiuUsata = '-';
    if (catMap.isNotEmpty) {
      final entries = catMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      categoriaPiuUsata = entries.first.key; 
    }

    // 2. Tempo medio di preparazione
    double avgPrepTime = 0; // In minuti
    if (ricette.isNotEmpty) {
      double totalTime = 0;
      for (final r in ricette) {
        totalTime += double.tryParse(r.tempoPreparazione) ?? 0;
      }
      avgPrepTime = totalTime / ricette.length;
    }

    // 3. Ingredienti più usati nelle ricette salvate
    final ingMap = <String, int>{}; // Mappa {NomeIngrediente: Conteggio}
    for (final r in ricette) {
      for (final ing in r.ingredienti) {
        ingMap[ing.nome] = (ingMap[ing.nome] ?? 0) + 1;
      }
    }
    // Ordina in modo decrescente e prendi i primi 5
    final topIngredients = ingMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = topIngredients.take(5).toList();

    // 4. Pasti pianificati nella settimana corrente
    final weeklyMealsCount = pianoPastiVM.numeroPastiPianificati;

    // 5. Prodotti in scadenza nei prossimi 7 giorni
    final oggi = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    final expiringItems = articoli.where((art) {
      // Tiene conto solo di prodotti con quantità > 0 e in scadenza a breve
      if (art.scadenza != null && art.quantita > 0) {
        final diff = art.scadenza!.difference(oggi).inDays;
        return diff >= 0 && diff <= 7;
      }
      return false;
    }).toList();

    // 6. Ingredienti mancanti rispetto al piano pasti odierno
    final dayOfWeek = _getGiornoOdierno();
    final pastiOggi = pianoPastiVM.pastiEffettivi.where((p) => p.giorno == dayOfWeek).toList();
    
    // Somma gli ingredienti richiesti oggi
    final ingredientiRichiesti = <String, double>{};
    for (final pasto in pastiOggi) {
      final ricetta = ricetteVM.ottieniRicettaPerId(pasto.idRicetta);
      if (ricetta != null) {
        for (final ing in ricetta.ingredienti) {
          final qta = double.tryParse(ing.quantita) ?? 1.0;
          ingredientiRichiesti[ing.nome] = (ingredientiRichiesti[ing.nome] ?? 0) + qta;
        }
      }
    }

    // Confronta il richiesto con ciò che c'è in dispensa
    int ingredientiMancantiCount = 0; // Contatore finale degli ingredienti mancanti
    for (final entry in ingredientiRichiesti.entries) {
      final inDispensa = articoli.where((a) => a.nome.toLowerCase() == entry.key.toLowerCase());
      double qtaInDispensa = 0;
      for (final a in inDispensa) {
        qtaInDispensa += a.quantita; 
      }
      
      if (qtaInDispensa < entry.value) {
        ingredientiMancantiCount++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CARDS PRINCIPALI ---
            _MockupStatCard(
              icon: Icons.menu_book_outlined,
              title: 'Ricette salvate',
              value: '${ricette.length}',
            ),
            _MockupStatCard(
              icon: Icons.calendar_month_outlined,
              title: 'Pasti pianificati questa settimana',
              value: '$weeklyMealsCount',
            ),
            _MockupStatCard(
              icon: Icons.access_time,
              title: 'Prodotti in scadenza nei prossimi 7 giorni',
              value: '${expiringItems.length}',
            ),
            _MockupStatCard(
              icon: Icons.pie_chart_outline,
              title: 'Categoria più usata',
              value: categoriaPiuUsata,
            ),
            _MockupStatCard(
              icon: Icons.schedule,
              title: 'Tempo medio di preparazione',
              value: '${avgPrepTime.toStringAsFixed(0)} min',
            ),
            // Segnala con testo rosso se mancano ingredienti per oggi
            _MockupStatCard(
              icon: Icons.shopping_cart_outlined,
              title: 'Ingredienti mancanti per oggi',
              value: '$ingredientiMancantiCount',
              valueColor: ingredientiMancantiCount > 0 ? AppStyle.coloreErrore : AppStyle.coloreTestoPrincipale,
            ),

            const SizedBox(height: 24),

            // --- STATISTICHE DETTAGLIATE ---
            Text(
              'Statistiche dettagliate',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppStyle.coloreTestoPrincipale,
              ),
            ),
            const SizedBox(height: 16),

            // Barre di progresso per gli ingredienti più usati
            if (top5.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppStyle.coloreBianco,
                  borderRadius: BorderRadius.circular(AppStyle.raggioCard),
                  boxShadow: AppStyle.ombraNuvola,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ingredienti più usati',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...top5.map((entry) {
                      final maxVal = top5.first.value.toDouble();
                      final val = entry.value.toDouble();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppStyle.coloreTestoPrincipale,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: maxVal > 0 ? val / maxVal : 0, 
                                  minHeight: 12,
                                  backgroundColor: Colors.grey.shade200,
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

            // Grafico a torta per la distribuzione delle ricette
            if (catMap.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppStyle.coloreBianco,
                  borderRadius: BorderRadius.circular(AppStyle.raggioCard),
                  boxShadow: AppStyle.ombraNuvola,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distribuzione per categoria',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: PieChart(
                            PieChartData(
                              sections: _buildPieSections(catMap),
                              centerSpaceRadius: 0,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildLegend(catMap),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Lista estesa dei prodotti in scadenza
            if (expiringItems.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppStyle.coloreBianco,
                  borderRadius: BorderRadius.circular(AppStyle.raggioCard),
                  boxShadow: AppStyle.ombraNuvola,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prodotti in scadenza',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...expiringItems.map((item) {
                      final isExpired = item.scadenza!.isBefore(oggi);
                      final diff = item.scadenza!.difference(oggi).inDays;
                      
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: Icon(
                          Icons.warning_amber_rounded, 
                          color: isExpired ? AppStyle.coloreErrore : Colors.orange, 
                        ),
                        title: Text(
                          item.nome,
                          style: TextStyle(color: AppStyle.coloreTestoPrincipale, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          isExpired ? 'SCADUTO' : 'Scade tra $diff giorni',
                          style: TextStyle(
                            color: isExpired ? AppStyle.coloreErrore : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getGiornoOdierno() {
    switch (DateTime.now().weekday) {
      case 1: return 'Lunedì';
      case 2: return 'Martedì';
      case 3: return 'Mercoledì';
      case 4: return 'Giovedì';
      case 5: return 'Venerdì';
      case 6: return 'Sabato';
      case 7: return 'Domenica';
      default: return 'Lunedì';
    }
  }

  static const List<Color> _chartColors = [
    AppStyle.colorePrimario,
    Color(0xFF8B928E), 
    Color(0xFFB0B7B3), 
    Color(0xFFD1D6D3), 
    Color(0xFFE2E6E4), 
    Colors.orangeAccent,
    Colors.teal,
  ];

  List<PieChartSectionData> _buildPieSections(Map<String, int> catMap) {
    int i = 0;
    final entries = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((entry) {
      final color = _chartColors[i % _chartColors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '', 
        radius: 60,
      );
    }).toList();
  }

  List<Widget> _buildLegend(Map<String, int> catMap) {
    int total = catMap.values.fold(0, (sum, val) => sum + val);
    int i = 0;
    final entries = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return entries.map((entry) {
      final color = _chartColors[i % _chartColors.length];
      final percentage = total > 0 ? (entry.value / total * 100).toStringAsFixed(0) : '0';
      i++;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.key,
                style: TextStyle(fontSize: 12, color: AppStyle.coloreTestoPrincipale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(fontSize: 12, color: AppStyle.coloreTestoPrincipale),
            ),
          ],
        ),
      );
    }).toList();
  }
}

// Visualizza le metriche riassuntive nello stile grafico pulito del mockup
class _MockupStatCard extends StatelessWidget {
  final IconData icon;       // Icona decorativa mostrata a sinistra
  final String title;        // Testo descrittivo sopra il valore numerico
  final String value;        // Valore numerico o testuale principale
  final Color? valueColor;   // Colore personalizzato per il valore (opzionale)

  const _MockupStatCard({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppStyle.coloreBianco,
        borderRadius: BorderRadius.circular(AppStyle.raggioCard),
        boxShadow: AppStyle.ombraNuvola, 
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 36,
            color: AppStyle.coloreTestoSecondario,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppStyle.coloreTestoPrincipale,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? AppStyle.coloreTestoPrincipale,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
