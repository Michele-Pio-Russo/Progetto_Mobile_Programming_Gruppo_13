import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../models/pantry_item.dart';

class PantryFormScreen extends StatefulWidget {
  final PantryItem? item;
  const PantryFormScreen({super.key, this.item});

  @override
  State<PantryFormScreen> createState() => _PantryFormScreenState();
}

class _PantryFormScreenState extends State<PantryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _qtyCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _thresholdCtrl;
  late String _category;
  late String _unit;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    final p = widget.item;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _qtyCtrl = TextEditingController(
        text: p != null
            ? '${p.quantity % 1 == 0 ? p.quantity.toInt() : p.quantity}'
            : '');
    _notesCtrl = TextEditingController(text: p?.notes ?? '');
    _thresholdCtrl = TextEditingController(
        text: p != null ? '${p.lowStockThreshold}' : '1');
    _category = p?.category ?? PantryItem.categories.first;
    _unit = p?.unit ?? PantryItem.units.first;
    _expiryDate = p?.expiryDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Nuovo prodotto' : 'Modifica prodotto'),
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
                    labelText: 'Nome prodotto *',
                    prefixIcon: Icon(Icons.kitchen)),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obbligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: PantryItem.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Quantità *',
                          prefixIcon: Icon(Icons.scale)),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Campo obbligatorio'
                          : null,
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
                controller: _thresholdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Soglia esaurimento',
                    prefixIcon: Icon(Icons.warning_amber_outlined),
                    helperText:
                        'Sotto questa quantità viene segnalato come in esaurimento'),
              ),
              const SizedBox(height: 12),
              // Data scadenza
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(_expiryDate == null
                    ? 'Data di scadenza (opzionale)'
                    : 'Scadenza: ${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'),
                trailing: _expiryDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _expiryDate = null),
                      )
                    : null,
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Note',
                    prefixIcon: Icon(Icons.notes)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    final item = PantryItem(
      id: widget.item?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      category: _category,
      quantity: double.tryParse(_qtyCtrl.text) ?? 0,
      unit: _unit,
      expiryDate: _expiryDate,
      notes: _notesCtrl.text.trim(),
      lowStockThreshold: double.tryParse(_thresholdCtrl.text) ?? 1.0,
    );
    if (widget.item == null) {
      provider.addPantryItem(item);
    } else {
      provider.updatePantryItem(item);
    }
    Navigator.pop(context);
  }
}
