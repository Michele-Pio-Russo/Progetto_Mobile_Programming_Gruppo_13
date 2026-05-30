import 'package:flutter/material.dart';
import 'dispensa/dispensa_view.dart';
import 'piano_pasti/piano_pasti_view.dart';
import 'lista_spesa/lista_spesa_view.dart';
import 'ricette/ricette_view.dart';

class SchermataPrincipale extends StatefulWidget {
  const SchermataPrincipale({super.key});

  @override
  State<SchermataPrincipale> createState() => _SchermataPrincipaleState();
}

class _SchermataPrincipaleState extends State<SchermataPrincipale> {
  int _indiceSelezionato = 1;

  final List<Widget> _pagine = const [
    RicetteView(),
    SchermataDispensa(),
    PianoPastiView(),
    ListaSpesaView(),
    Center(child: Text('Schermata Statistiche (Da implementare)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pagine[_indiceSelezionato],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _indiceSelezionato,
        selectedItemColor: Colors.grey.shade800,
        unselectedItemColor: Colors.grey.shade400,
        onTap: (int nuovoIndice) {
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
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistiche',
          ),
        ],
      ),
    );
  }
}