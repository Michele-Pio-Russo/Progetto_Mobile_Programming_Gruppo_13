import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/recipe.dart';
import '../../utils/app_theme.dart';
import 'recipe_form_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final recipe = context.watch<AppProvider>().recipeById(recipeId);
    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ricetta')),
        body: const Center(child: Text('Ricetta non trovata.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => RecipeFormScreen(recipe: recipe)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, recipe),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header chips
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _Chip(icon: Icons.category, label: recipe.category),
                _Chip(
                    icon: Icons.access_time,
                    label: '${recipe.prepTimeMinutes} min'),
                _Chip(icon: Icons.bar_chart, label: recipe.difficulty),
                _Chip(
                    icon: Icons.people,
                    label: '${recipe.servings} porz.'),
              ],
            ),
            const SizedBox(height: 20),

            // Descrizione
            if (recipe.description.isNotEmpty) ...[
              _SectionTitle('Procedimento'),
              Text(recipe.description, style: const TextStyle(fontSize: 15, height: 1.6)),
              const SizedBox(height: 20),
            ],

            // Ingredienti
            _SectionTitle('Ingredienti'),
            ...recipe.ingredients.map((ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.fiber_manual_record,
                          size: 8, color: AppTheme.primary),
                      const SizedBox(width: 10),
                      Expanded(child: Text(ing.name, style: const TextStyle(fontSize: 15))),
                      Text(
                        '${ing.quantity % 1 == 0 ? ing.quantity.toInt() : ing.quantity} ${ing.unit}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: AppTheme.primary),
                      ),
                    ],
                  ),
                )),

            // Note
            if (recipe.notes.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle('Note'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Text(recipe.notes),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina ricetta'),
        content: Text('Vuoi eliminare "${recipe.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla')),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteRecipe(recipe.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.primary)),
      );
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Chip(
        avatar: Icon(icon, size: 16, color: AppTheme.primary),
        label: Text(label),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      );
}
