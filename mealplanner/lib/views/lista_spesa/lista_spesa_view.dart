import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/lista_spesa_viewmodel.dart';
import 'lista_spesa_aggiunta_view.dart';

class ListaSpesaView extends StatelessWidget {
  const ListaSpesaView({super.key});

  void _mostraDialogConferma(BuildContext context, ListaSpesaViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma rimozione'),
          content: const Text('Vuoi davvero rimuovere tutti gli articoli marcati come comprati?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                viewModel.rimuoviProdottiComprati();
                Navigator.pop(context);
              },
              child: const Text('Rimuovi', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lista della Spesa',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Consumer<ListaSpesaViewModel>(
            builder: (context, viewModel, child) {
              final haProdottiComprati = viewModel.prodotti.any((p) => p.comprato);
              if (!haProdottiComprati) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.black),
                onPressed: () => _mostraDialogConferma(context, viewModel),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SchermataAggiuntaSpesa(),
            ),
          );
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        shape: const CircleBorder(side: BorderSide(color: Colors.white30)),
        child: const Icon(Icons.add, size: 28),
      ),
      body: Consumer<ListaSpesaViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.prodotti.isEmpty) {
            return const Center(
              child: Text(
                'La lista della spesa è vuota.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.prodotti.length,
            itemBuilder: (context, index) {
              final prodotto = viewModel.prodotti[index];

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  leading: Checkbox(
                    value: prodotto.comprato,
                    activeColor: Colors.black,
                    onChanged: (bool? valore) {
                      viewModel.toggleComprato(prodotto.id);
                    },
                  ),
                  title: Text(
                    prodotto.nome,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: prodotto.comprato
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: prodotto.comprato ? Colors.grey : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    prodotto.quantita,
                    style: TextStyle(
                      color: prodotto.comprato ? Colors.grey : Colors.black87,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SchermataAggiuntaSpesa(prodotto: prodotto),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          viewModel.rimuoviProdotto(prodotto.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}