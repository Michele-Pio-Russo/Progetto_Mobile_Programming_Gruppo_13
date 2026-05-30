import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/lista_spesa_viewmodel.dart';
import '../../models/lista_spesa_model.dart';

class SchermataAggiuntaSpesa extends StatefulWidget {
  final ListaSpesa? prodotto;

  const SchermataAggiuntaSpesa({super.key, this.prodotto});

  @override
  State<SchermataAggiuntaSpesa> createState() => _SchermataAggiuntaSpesaState();
}

class _SchermataAggiuntaSpesaState extends State<SchermataAggiuntaSpesa> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantitaController = TextEditingController();
  
  String _unitaSelezionata = 'pezzi';
  final List<String> _unitaMisura = ['g', 'kg', 'ml', 'l', 'pezzi', 'confezioni'];

  @override
  void initState() {
    super.initState();
    if (widget.prodotto != null) {
      _nomeController.text = widget.prodotto!.nome;
      if (widget.prodotto!.quantita != '-') {
        final parti = widget.prodotto!.quantita.split(' ');
        if (parti.length >= 2) {
          _quantitaController.text = parti[0];
          if (_unitaMisura.contains(parti[1])) {
            _unitaSelezionata = parti[1];
          }
        } else if (parti.length == 1) {
          _quantitaController.text = parti[0];
        }
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantitaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ListaSpesaViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.prodotto == null ? 'Nuovo prodotto' : 'Modifica prodotto',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nome prodotto',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                hintText: 'Es. Latte, Uova, Pane...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quantità',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _quantitaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*')),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Es. 2, 1.5...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unità di misura',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _unitaSelezionata,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        items: _unitaMisura.map((String unita) {
                          return DropdownMenuItem<String>(
                            value: unita,
                            child: Text(unita),
                          );
                        }).toList(),
                        onChanged: (nuovaUnita) {
                          setState(() {
                            if (nuovaUnita != null) {
                              _unitaSelezionata = nuovaUnita;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  String nome = _nomeController.text.trim();
                  String numeroQuantita = _quantitaController.text.trim().replaceAll(',', '.');

                  if (nome.isNotEmpty) {
                    String quantitaFinale = '-';
                    if (numeroQuantita.isNotEmpty) {
                      quantitaFinale = '$numeroQuantita $_unitaSelezionata';
                    }

                    if (widget.prodotto == null) {
                      viewModel.aggiungiProdotto(nome, quantitaFinale);
                    } else {
                      viewModel.modificaProdotto(widget.prodotto!.id, nome, quantitaFinale);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  widget.prodotto == null ? 'Aggiungi alla lista' : 'Salva modifiche',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}