import 'package:flutter/material.dart';
import '../../models/ricette_model.dart';
import '../../theme/style.dart';


/// Schermata di visualizzazione in sola lettura.
/// Mostra tutti i dettagli di una singola [Ricette] passata al costruttore,
/// includendo categoria, tempo, difficoltà, lista degli ingredienti formattata e procedimento.
class RicetteDettaglioView extends StatelessWidget {
  /// L'oggetto ricetta di cui mostrare i dettagli.
  final Ricette ricetta;

  /// Costruttore che richiede obbligatoriamente l'oggetto [ricetta]
  const RicetteDettaglioView({super.key, required this.ricetta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Ricetta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo e Categoria
            Text(ricetta.titolo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppStyle.colorePrimario.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppStyle.raggioBottoni),
              ),
              child: Text(
                ricetta.categoria,
                style: const TextStyle(color: AppStyle.colorePrimario, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Informazioni Rapide (Tempo, Difficoltà, Quantità)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mostriamo il tempo aggiungendo "min" e la difficoltà usando il costruttore delle fiammelle
                _buildInfoBadge(Icons.timer_outlined, '${ricetta.tempoPreparazione} min'),
                _buildDifficoltaBadge(ricetta.difficolta),
                _buildInfoBadge(Icons.restaurant_outlined, ricetta.quantita),
              ],
            ),
            const Divider(height: 40, thickness: 1),

            // Ingredienti
            const Text('Ingredienti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...ricetta.ingredienti.map((ing) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: AppStyle.colorePrimario),
                      const SizedBox(width: 10),
                      Expanded(
                        // Formattiamo gli ingredienti strutturati: omettiamo l'unità se è "altro"
                        child: Text(
                          '${ing.nome} - ${ing.quantita} ${ing.unitaMisura == "altro" ? "" : ing.unitaMisura}'.trimRight(), 
                          style: const TextStyle(fontSize: 16)
                        ),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 40, thickness: 1),

            // Procedimento
            const Text('Procedimento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(ricetta.preparazione, style: const TextStyle(fontSize: 16, height: 1.5)),
            
            // Note
            if (ricetta.note.isNotEmpty) ...[
              const Divider(height: 40, thickness: 1),
              const Text('Note', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppStyle.coloreTestoSecondario.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppStyle.coloreTestoSecondario.withValues(alpha: 0.2)),
                ),
                child: Text(ricetta.note, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
              ),
            ],
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Costruisce una piccola colonna contenente un'icona e una label di testo.
  /// È utilizzata per la sezione di informazioni rapide (es. tempo di preparazione e porzioni).
  Widget _buildInfoBadge(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppStyle.coloreTestoSecondario, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  /// Costruisce il badge per la difficoltà della ricetta.
  /// Disegna fino a 5 fiammelle e colora di arancione un numero di fiammelle pari a [difficolta],
  /// lasciando le restanti grigie e traslucide.
  Widget _buildDifficoltaBadge(int difficolta) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // Genera una lista di 5 widget Icon (le fiammelle)
            children: List.generate(5, (index) {
              return Icon(
                Icons.local_fire_department_outlined,
                // index va da 0 a 4. Se è minore della difficoltà (1-5), accendiamo la fiamma
                color: index < difficolta ? Colors.orange : AppStyle.coloreTestoSecondario.withValues(alpha: 0.2),
                size: 24,
              );
            }),
          ),
          const SizedBox(height: 8),
          const Text('Difficoltà', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}