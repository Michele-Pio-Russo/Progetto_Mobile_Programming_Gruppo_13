import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../models/recipe.dart';
import '../../utils/app_theme.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe;
  const RecipeFormScreen({super.key, this.recipe});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _prepTimeCtrl;
  late TextEditingController _servingsCtrl;
  late String _category;
  late String _difficulty;
  late List<RecipeIngredient> _ingredients;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _notesCtrl = TextEditingController(text: r?.notes ?? '');
    _prepTimeCtrl =
        TextEditingController(text: r != null ? '${r.prepTimeMinutes}' : '');
    _servingsCtrl =
        TextEditingController(text: r != null ? '${r.servings}' : '');
    _category = r?.category ?? Recipe.categories.first;
    _difficulty = r?.difficulty ?? Recipe.difficulties.first;
    _ingredients = r != null ? List.from(r.ingredients) : [];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    _prepTimeCtrl.dispose();
    _servingsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.recipe != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifica ricetta' : 'Nuova ricetta'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Salva',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              _buildTextField(_nameCtrl, 'Nome ricetta *', Icons.restaurant,
                  required: true),
              const SizedBox(height: 12),
              _buildDropdown('Categoria', _category, Recipe.categories,
                  (v) => setState(() => _category = v!)),
              const SizedBox(height: 12),
              _buildDropdown('Difficoltà', _difficulty, Recipe.difficulties,
                  (v) => setState(() => _difficulty = v!)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          _prepTimeCtrl, 'Tempo (min) *', Icons.access_time,
                          keyboardType: TextInputType.number, required: true)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTextField(
                          _servingsCtrl, 'Porzioni *', Icons.people,
                          keyboardType: TextInputType.number, required: true)),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(_descCtrl, 'Procedimento', Icons.notes,
                  maxLines: 5),
              const SizedBox(height: 12),
              _buildTextField(_notesCtrl, 'Note aggiuntive', Icons.info_outline,
                  maxLines: 2),
              const SizedBox(height: 20),
              _buildIngredientsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null
            : null,
      );

  Widget _buildDropdown(String label, String value, List<String> items,
          ValueChanged<String?> onChanged) =>
      DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
      );

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Ingredienti',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary)),
            TextButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi'),
            ),
          ],
        ),
        if (_ingredients.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Nessun ingrediente aggiunto.',
                style: TextStyle(color: Colors.grey)),
          ),
        ..._ingredients.asMap().entries.map((e) {
          final idx = e.key;
          final ing = e.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              dense: true,
              title: Text(ing.name),
              subtitle: Text(
                  '${ing.quantity % 1 == 0 ? ing.quantity.toInt() : ing.quantity} ${ing.unit}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () =>
                    setState(() => _ingredients.removeAt(idx)),
              ),
              onTap: () => _editIngredient(idx),
            ),
          );
        }),
      ],
    );
  }

  void _addIngredient() => _showIngredientDialog(null, -1);
  void _editIngredient(int idx) => _showIngredientDialog(_ingredients[idx], idx);

  void _showIngredientDialog(RecipeIngredient? ing, int idx) {
    final nameCtrl = TextEditingController(text: ing?.name ?? '');
    final qtyCtrl = TextEditingController(
        text: ing != null
            ? '${ing.quantity % 1 == 0 ? ing.quantity.toInt() : ing.quantity}'
            : '');
    String unit = ing?.unit ?? 'g';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(idx == -1 ? 'Aggiungi ingrediente' : 'Modifica ingrediente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome ingrediente'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantità'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: unit,
                    items: ['g', 'kg', 'ml', 'l', 'pz', 'cucchiai', 'tazze', 'q.b.']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setS(() => unit = v!),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla')),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final newIng = RecipeIngredient(
                  name: nameCtrl.text.trim(),
                  quantity: double.tryParse(qtyCtrl.text) ?? 1,
                  unit: unit,
                );
                setState(() {
                  if (idx == -1) {
                    _ingredients.add(newIng);
                  } else {
                    _ingredients[idx] = newIng;
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    final recipe = Recipe(
      id: widget.recipe?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      prepTimeMinutes: int.tryParse(_prepTimeCtrl.text) ?? 0,
      difficulty: _difficulty,
      servings: int.tryParse(_servingsCtrl.text) ?? 1,
      ingredients: _ingredients,
      notes: _notesCtrl.text.trim(),
      createdAt: widget.recipe?.createdAt ?? DateTime.now(),
    );
    if (widget.recipe == null) {
      provider.addRecipe(recipe);
    } else {
      provider.updateRecipe(recipe);
    }
    Navigator.pop(context);
  }
}
