import 'package:flutter/material.dart';
import '../views/dispensa/dispensa_view.dart';

class SchermataPrincipale extends StatefulWidget {
  const SchermataPrincipale({super.key});

  @override
  State<SchermataPrincipale> createState() => _SchermataPrincipaleState();
}

class _SchermataPrincipaleState extends State<SchermataPrincipale> {
  int _indiceSelezionato = 1; // Partiamo da 1 così l'app si apre direttamente sulla Dispensa

  // Elenco delle schermate collegate ai bottoni in basso
  final List<Widget> _pagine = [
    const Center(child: Text('Schermata Ricette (Da implementare)')),     // Indice 0
    const SchermataDispensa(),                                            // Indice 1 (La tua dispensa)
    const Center(child: Text('Schermata Piano Pasti (Da implementare)')),  // Indice 2
    const Center(child: Text('Schermata Lista Spesa (Da implementare)')),  // Indice 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mostra la pagina attualmente selezionata in base all'indice
      body: _pagine[_indiceSelezionato],
      
      // La barra di navigazione inferiore 
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _indiceSelezionato,
        selectedItemColor: Colors.grey.shade800,
        unselectedItemColor: Colors.grey.shade400,
        onTap: (int nuovoIndice) {
          // Quando l'utente clicca su un'icona, cambiamo l'indice e aggiorniamo lo schermo
          setState(() {
            _indiceSelezionato = nuovoIndice;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Ricette',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'Dispensa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Piano Pasti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Spesa',
          ),
        ],
      ),
    );
  }
}