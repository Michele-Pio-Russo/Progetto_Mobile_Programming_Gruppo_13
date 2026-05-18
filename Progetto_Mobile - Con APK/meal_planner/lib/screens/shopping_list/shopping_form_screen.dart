import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../models/shopping_item.dart';
import '../../models/pantry_item.dart';

class ShoppingFormScreen extends StatefulWidget {
  final ShoppingItem? item;
  const ShoppingFormScreen({super.key, this.item});

  @override
  State<ShoppingFormScreen> createState() => _ShoppingFormScreenState();
}

class _ShoppingFormScreenState extends State<ShoppingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _qtyCtrl;
  late TextEditingController _notesCtrl;
  late String _unit;

  @override
  void initState() {
    super.initState();
    final s = widget.item;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _qtyCtrl = TextEditingController(
        text: s != null
            ? '${s.quantity % 1 == 0 ? s.quantity.toInt() : s.quantity}'
            : '1');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
    _unit = s?.unit ?? 'pz';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Aggiungi articolo' : 'Modifica articolo'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Salva',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome articolo *',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obbligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantità'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _unit,
                      decoration: const InputDecoration(labelText: 'Unità'),
                      items: PantryItem.units
                          .map((u) =>
                              DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) => setState(() => _unit = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Note', prefixIcon: Icon(Icons.notes)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    final item = ShoppingItem(
      id: widget.item?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      quantity: double.tryParse(_qtyCtrl.text) ?? 1,
      unit: _unit,
      isPurchased: widget.item?.isPurchased ?? false,
      sourceRecipeId: widget.item?.sourceRecipeId,
      notes: _notesCtrl.text.trim(),
    );
    if (widget.item == null) {
      provider.addShoppingItem(item);
    } else {
      provider.updateShoppingItem(item);
    }
    Navigator.pop(context);
  }
}
