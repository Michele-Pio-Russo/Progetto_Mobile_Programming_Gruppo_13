import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/ricette_viewmodel.dart';
import '../../models/ricette_model.dart';
import 'ricette_modifica_view.dart';

class RicetteView extends StatefulWidget {
  const RicetteView({super.key});

  @override
  State<RicetteView> createState() => _RicetteViewState();
}

class _RicetteViewState extends State<RicetteView> {
  String _categoriaSelezionata = 'Tutte';
  String _queryRicerca = '';

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RicetteViewModel>(context);
    
    // Filtra prima per ricerca testuale, poi per categoria
    List<Ricette> ricetteFiltrate = viewModel.cercaRicette(_queryRicerca);
    if (_categoriaSelezionata != 'Tutte') {
      ricetteFiltrate = ricetteFiltrate.where((r) => r.categoria == _categoriaSelezionata).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ricette', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RicetteModificaView()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra di Ricerca e Filtro Categoria
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: (valore) {
                      setState(() {
                        _queryRicerca = valore;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cerca...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _categoriaSelezionata,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    items: ['Tutte', ...Ricette.categorie].map((String cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (nuovoValore) {
                      setState(() {
                        _categoriaSelezionata = nuovoValore!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Lista delle Ricette
          Expanded(
            child: ricetteFiltrate.isEmpty
                ? const Center(child: Text('Nessuna ricetta trovata.'))
                : ListView.builder(
                    itemCount: ricetteFiltrate.length,
                    itemBuilder: (context, index) {
                      final ricetta = ricetteFiltrate[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RicetteModificaView(ricetta: ricetta),
                              ),
                            );
                          },
                          leading: Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.restaurant, color: Colors.grey),
                          ),
                          title: Text(ricetta.titolo, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            ricetta.preparazione,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              ricetta.categoria,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
