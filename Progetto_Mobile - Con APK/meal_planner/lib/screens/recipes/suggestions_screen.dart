import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import 'recipe_detail_screen.dart';

class SuggestionsScreen extends StatelessWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final suggestions = provider.suggestRecipesFromPantry();
    final pantryNames =
        provider.pantryItems.map((p) => p.name.toLowerCase()).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ricette suggerite'),
        backgroundColor: AppTheme.secondary,
      ),
      body: suggestions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb_outline, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nessun suggerimento disponibile.\nAggiungi prodotti alla dispensa!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: suggestions.length,
              itemBuilder: (ctx, i) {
                final recipe = suggestions[i];
                final matching = recipe.ingredients
                    .where((ing) => pantryNames.contains(ing.name.toLowerCase()))
                    .length;
                final total = recipe.ingredients.length;
                final pct = total > 0 ? matching / total : 0.0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              RecipeDetailScreen(recipeId: recipe.id)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.restaurant,
                                  color: AppTheme.secondary),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(recipe.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))),
                              Text('$matching/$total ingredienti',
                                  style: const TextStyle(
                                      color: AppTheme.secondary,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: pct,
                            color: AppTheme.secondary,
                            backgroundColor: Colors.grey.shade200,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: recipe.ingredients.map((ing) {
                              final available =
                                  pantryNames.contains(ing.name.toLowerCase());
                              return Chip(
                                label: Text(ing.name,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: available
                                            ? Colors.green.shade800
                                            : Colors.red.shade800)),
                                backgroundColor: available
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
