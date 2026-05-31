import 'package:flutter/material.dart';

import '../theme/style.dart';

import 'dispensa/dispensa_view.dart';
import 'piano_pasti/piano_pasti_view.dart';
import 'lista_spesa/lista_spesa_view.dart';
import 'ricette/ricette_view.dart';
import 'statistiche/statistiche_view.dart';

class SchermataPrincipale extends StatefulWidget {
  const SchermataPrincipale({super.key});

  @override
  State<SchermataPrincipale> createState() => _SchermataPrincipaleState();
}

// Collega le schermate alla navigation bar, partendo dalla prima (dispensa)
class _SchermataPrincipaleState extends State<SchermataPrincipale> {
  int _indiceSelezionato = 0;

  final List<Widget> _pagine = [
    const SchermataDispensa(),
    const RicetteView(),
    const PianoPastiView(),
    const ListaSpesaView(),
    const StatisticheView(),
  ];

// Setting degli indici delle schermate, stili e icone
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pagine[_indiceSelezionato],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppStyle.coloreSfondo,
        currentIndex: _indiceSelezionato,
        selectedItemColor: AppStyle.colorePrimario,
        unselectedItemColor: AppStyle.coloreTestoSecondario,
        onTap: (int nuovoIndice) {
          setState(() {
            _indiceSelezionato = nuovoIndice;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _indiceSelezionato == 0 ? Icons.kitchen : Icons.kitchen_outlined,
            ),
            label: 'Dispensa',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _indiceSelezionato == 1
                  ? Icons.restaurant_menu
                  : Icons.restaurant_menu_outlined,
            ),
            label: 'Ricette',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _indiceSelezionato == 2
                  ? Icons.calendar_month
                  : Icons.calendar_month_outlined,
            ),
            label: 'Piano Pasti',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _indiceSelezionato == 3
                  ? Icons.shopping_cart
                  : Icons.shopping_cart_outlined,
            ),
            label: 'Spesa',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _indiceSelezionato == 4
                  ? Icons.bar_chart
                  : Icons.bar_chart_outlined,
            ),
            label: 'Statistiche',
          ),
        ],
      ),
    );
  }
}
