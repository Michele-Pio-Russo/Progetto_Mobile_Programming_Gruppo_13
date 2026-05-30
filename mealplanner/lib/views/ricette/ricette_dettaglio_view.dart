import 'package:flutter/material.dart';
import '../../models/ricette_model.dart';

class RicetteDettaglioView extends StatelessWidget {
  final Ricette ricetta;

  const RicetteDettaglioView({super.key, required this.ricetta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Ricetta', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ricetta.categoria,
                style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Informazioni Rapide (Tempo, Difficoltà, Quantità)
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoBadge(Icons.timer, '${ricetta.tempoPreparazione} min'),
                _buildDifficoltaBadge(ricetta.difficolta),
                _buildInfoBadge(Icons.restaurant, ricetta.quantita),
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
                      const Icon(Icons.circle, size: 8, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
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
                  color: Colors.yellow.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow.shade200),
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

  Widget _buildInfoBadge(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDifficoltaBadge(int difficolta) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                Icons.local_fire_department,
                color: index < difficolta ? Colors.orange : Colors.grey.shade300,
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
