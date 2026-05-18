import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../models/meal_entry.dart';

class MealFormScreen extends StatefulWidget {
  final DateTime date;
  final MealEntry? meal;
  const MealFormScreen({super.key, required this.date, this.meal});

  @override
  State<MealFormScreen> createState() => _MealFormScreenState();
}

class _MealFormScreenState extends State<MealFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _mealType;
  late TextEditingController _labelCtrl;
  late TextEditingController _notesCtrl;
  String? _selectedRecipeId;

  @override
  void initState() {
    super.initState();
    final m = widget.meal;
    _mealType = m?.mealType ?? MealEntry.mealTypes.first;
    _labelCtrl = TextEditingController(text: m?.customLabel ?? '');
    _notesCtrl = TextEditingController(text: m?.notes ?? '');
    _selectedRecipeId = m?.recipeId;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final recipes = provider.recipes;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal == null ? 'Aggiungi pasto' : 'Modifica pasto'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date display
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat('EEEE d MMMM yyyy', 'it')
                    .format(widget.date)),
              ),
              const Divider(),
              const SizedBox(height: 8),
              // Meal type
              DropdownButtonFormField<String>(
                value: _mealType,
                decoration: const InputDecoration(labelText: 'Tipo di pasto'),
                items: MealEntry.mealTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _mealType = v!),
              ),
              const SizedBox(height: 16),
              // Recipe selector
              const Text('Ricetta (opzionale)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRecipeId,
                decoration: const InputDecoration(
                    hintText: 'Seleziona una ricetta...'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Nessuna ricetta')),
                  ...recipes.map((r) =>
                      DropdownMenuItem(value: r.id, child: Text(r.name))),
                ],
                onChanged: (v) => setState(() {
                  _selectedRecipeId = v;
                  if (v != null) {
                    final recipe = provider.recipeById(v);
                    if (recipe != null && _labelCtrl.text.isEmpty) {
                      _labelCtrl.text = recipe.name;
                    }
                  }
                }),
              ),
              const SizedBox(height: 16),
              // Custom label
              TextFormField(
                controller: _labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrizione pasto *',
                  prefixIcon: Icon(Icons.restaurant),
                  helperText:
                      'Inserisci una descrizione se non hai selezionato una ricetta',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Inserisci una descrizione'
                    : null,
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
    final entry = MealEntry(
      id: widget.meal?.id ?? const Uuid().v4(),
      date: widget.date,
      mealType: _mealType,
      recipeId: _selectedRecipeId,
      customLabel: _labelCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );
    if (widget.meal == null) {
      provider.addMealEntry(entry);
    } else {
      provider.updateMealEntry(entry);
    }
    Navigator.pop(context);
  }
}
