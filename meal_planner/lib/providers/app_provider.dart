import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import '../models/pantry_item.dart';
import '../models/meal_entry.dart';
import '../models/shopping_item.dart';

class AppProvider extends ChangeNotifier {
  static const _uuid = Uuid();

  // ─── State ────────────────────────────────────────────────────────────────
  List<Recipe> _recipes = [];
  List<PantryItem> _pantryItems = [];
  List<MealEntry> _mealEntries = [];
  List<ShoppingItem> _shoppingItems = [];
  bool _isLoading = true;
  int _expiryWarningDays = 3; // soglia configurabile "in scadenza"

  // ─── Getters ──────────────────────────────────────────────────────────────
  List<Recipe> get recipes => List.unmodifiable(_recipes);
  List<PantryItem> get pantryItems => List.unmodifiable(_pantryItems);
  List<MealEntry> get mealEntries => List.unmodifiable(_mealEntries);
  List<ShoppingItem> get shoppingItems => List.unmodifiable(_shoppingItems);
  bool get isLoading => _isLoading;
  int get expiryWarningDays => _expiryWarningDays;

  void setExpiryWarningDays(int days) {
    _expiryWarningDays = days;
    notifyListeners();
  }

  // ─── Init ─────────────────────────────────────────────────────────────────
  AppProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final recipesJson = prefs.getString('recipes');
    if (recipesJson != null) {
      final list = jsonDecode(recipesJson) as List;
      _recipes = list.map((j) => Recipe.fromJson(j)).toList();
    } else {
      _recipes = _sampleRecipes();
    }

    final pantryJson = prefs.getString('pantry');
    if (pantryJson != null) {
      final list = jsonDecode(pantryJson) as List;
      _pantryItems = list.map((j) => PantryItem.fromJson(j)).toList();
    } else {
      _pantryItems = _samplePantry();
    }

    final mealsJson = prefs.getString('meals');
    if (mealsJson != null) {
      final list = jsonDecode(mealsJson) as List;
      _mealEntries = list.map((j) => MealEntry.fromJson(j)).toList();
    } else {
      _mealEntries = _sampleMeals();
    }

    final shoppingJson = prefs.getString('shopping');
    if (shoppingJson != null) {
      final list = jsonDecode(shoppingJson) as List;
      _shoppingItems = list.map((j) => ShoppingItem.fromJson(j)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'recipes', jsonEncode(_recipes.map((r) => r.toJson()).toList()));
    await prefs.setString(
        'pantry', jsonEncode(_pantryItems.map((p) => p.toJson()).toList()));
    await prefs.setString(
        'meals', jsonEncode(_mealEntries.map((m) => m.toJson()).toList()));
    await prefs.setString('shopping',
        jsonEncode(_shoppingItems.map((s) => s.toJson()).toList()));
  }

  // ─── Recipes ──────────────────────────────────────────────────────────────
  void addRecipe(Recipe recipe) {
    _recipes.add(recipe.copyWith(id: _uuid.v4()));
    _save();
    notifyListeners();
  }

  void updateRecipe(Recipe recipe) {
    final idx = _recipes.indexWhere((r) => r.id == recipe.id);
    if (idx != -1) {
      _recipes[idx] = recipe;
      _save();
      notifyListeners();
    }
  }

  void deleteRecipe(String id) {
    _recipes.removeWhere((r) => r.id == id);
    _mealEntries.removeWhere((m) => m.recipeId == id);
    _save();
    notifyListeners();
  }

  Recipe? recipeById(String id) =>
      _recipes.cast<Recipe?>().firstWhere((r) => r?.id == id, orElse: () => null);

  List<Recipe> searchRecipes({String query = '', String category = ''}) {
    return _recipes.where((r) {
      final matchesQuery =
          query.isEmpty || r.name.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category.isEmpty || r.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  // ─── Pantry ───────────────────────────────────────────────────────────────
  void addPantryItem(PantryItem item) {
    _pantryItems.add(item.copyWith(id: _uuid.v4()));
    _save();
    notifyListeners();
  }

  void updatePantryItem(PantryItem item) {
    final idx = _pantryItems.indexWhere((p) => p.id == item.id);
    if (idx != -1) {
      _pantryItems[idx] = item;
      _save();
      notifyListeners();
    }
  }

  void deletePantryItem(String id) {
    _pantryItems.removeWhere((p) => p.id == id);
    _save();
    notifyListeners();
  }

  List<PantryItem> get expiringItems => _pantryItems
      .where((p) => p.isExpiringSoonWithin(_expiryWarningDays) || p.isExpired)
      .toList()
    ..sort((a, b) {
      if (a.isExpired && !b.isExpired) return -1;
      if (!a.isExpired && b.isExpired) return 1;
      final da = a.daysUntilExpiry ?? 999;
      final db = b.daysUntilExpiry ?? 999;
      return da.compareTo(db);
    });

  List<PantryItem> get expiredItems =>
      _pantryItems.where((p) => p.isExpired).toList();

  void deleteExpiredItems() {
    _pantryItems.removeWhere((p) => p.isExpired);
    _save();
    notifyListeners();
  }

  List<PantryItem> get lowStockItems =>
      _pantryItems.where((p) => p.isLowStock).toList();

  List<PantryItem> searchPantry({String query = '', String category = ''}) {
    return _pantryItems.where((p) {
      final matchesQuery =
          query.isEmpty || p.name.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category.isEmpty || p.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  // ─── Meal Plan ────────────────────────────────────────────────────────────
  void addMealEntry(MealEntry entry) {
    _mealEntries.add(entry.copyWith(id: _uuid.v4()));
    _save();
    notifyListeners();
  }

  void updateMealEntry(MealEntry entry) {
    final idx = _mealEntries.indexWhere((m) => m.id == entry.id);
    if (idx != -1) {
      _mealEntries[idx] = entry;
      _save();
      notifyListeners();
    }
  }

  void deleteMealEntry(String id) {
    _mealEntries.removeWhere((m) => m.id == id);
    _save();
    notifyListeners();
  }

  List<MealEntry> mealsForDate(DateTime date) {
    return _mealEntries
        .where((m) =>
            m.date.year == date.year &&
            m.date.month == date.month &&
            m.date.day == date.day)
        .toList()
      ..sort((a, b) => MealEntry.mealTypes
          .indexOf(a.mealType)
          .compareTo(MealEntry.mealTypes.indexOf(b.mealType)));
  }

  List<MealEntry> mealsForWeek(DateTime startOfWeek) {
    final end = startOfWeek.add(const Duration(days: 7));
    return _mealEntries
        .where((m) =>
            m.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            m.date.isBefore(end))
        .toList();
  }

  // ─── Shopping List ────────────────────────────────────────────────────────
  void addShoppingItem(ShoppingItem item) {
    _shoppingItems.add(item.copyWith(id: _uuid.v4()));
    _save();
    notifyListeners();
  }

  void updateShoppingItem(ShoppingItem item) {
    final idx = _shoppingItems.indexWhere((s) => s.id == item.id);
    if (idx != -1) {
      _shoppingItems[idx] = item;
      _save();
      notifyListeners();
    }
  }

  void toggleShoppingItem(String id) {
    final idx = _shoppingItems.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _shoppingItems[idx] =
          _shoppingItems[idx].copyWith(isPurchased: !_shoppingItems[idx].isPurchased);
      _save();
      notifyListeners();
    }
  }

  void deleteShoppingItem(String id) {
    _shoppingItems.removeWhere((s) => s.id == id);
    _save();
    notifyListeners();
  }

  void clearPurchasedItems() {
    _shoppingItems.removeWhere((s) => s.isPurchased);
    _save();
    notifyListeners();
  }

  /// Feature avanzata: genera la lista della spesa dal piano pasti della settimana
  void generateShoppingListFromMealPlan(DateTime weekStart) {
    final meals = mealsForWeek(weekStart);
    final Map<String, ShoppingItem> aggregated = {};

    for (final meal in meals) {
      if (meal.recipeId == null) continue;
      final recipe = recipeById(meal.recipeId!);
      if (recipe == null) continue;

      for (final ing in recipe.ingredients) {
        // controlla se già in dispensa con quantità sufficiente
        final inPantry = _pantryItems
            .where((p) =>
                p.name.toLowerCase() == ing.name.toLowerCase() &&
                p.unit == ing.unit)
            .fold<double>(0, (sum, p) => sum + p.quantity);

        final needed = ing.quantity - inPantry;
        if (needed <= 0) continue;

        final key = '${ing.name.toLowerCase()}||${ing.unit}';
        if (aggregated.containsKey(key)) {
          final existing = aggregated[key]!;
          aggregated[key] = existing.copyWith(
            quantity: existing.quantity + needed,
          );
        } else {
          aggregated[key] = ShoppingItem(
            id: _uuid.v4(),
            name: ing.name,
            quantity: needed,
            unit: ing.unit,
            isPurchased: false,
            sourceRecipeId: meal.recipeId,
            notes: 'Generato da: ${recipe.name}',
          );
        }
      }
    }

    // rimuovi gli items già generati automaticamente e reinserisci
    _shoppingItems.removeWhere((s) => s.sourceRecipeId != null);
    _shoppingItems.addAll(aggregated.values);
    _save();
    notifyListeners();
  }

  /// Feature avanzata: suggerisce ricette basate sugli ingredienti in dispensa
  List<Recipe> suggestRecipesFromPantry() {
    final pantryNames =
        _pantryItems.map((p) => p.name.toLowerCase()).toSet();

    return _recipes.where((recipe) {
      if (recipe.ingredients.isEmpty) return false;
      int matching = recipe.ingredients
          .where((ing) => pantryNames.contains(ing.name.toLowerCase()))
          .length;
      return matching / recipe.ingredients.length >= 0.5;
    }).toList()
      ..sort((a, b) {
        int aMatch = a.ingredients
            .where((i) => pantryNames.contains(i.name.toLowerCase()))
            .length;
        int bMatch = b.ingredients
            .where((i) => pantryNames.contains(i.name.toLowerCase()))
            .length;
        return bMatch.compareTo(aMatch);
      });
  }

  // ─── Statistics ───────────────────────────────────────────────────────────
  Map<String, int> get recipesByCategory {
    final map = <String, int>{};
    for (final r in _recipes) {
      map[r.category] = (map[r.category] ?? 0) + 1;
    }
    return map;
  }

  double get avgPrepTime {
    if (_recipes.isEmpty) return 0;
    return _recipes.map((r) => r.prepTimeMinutes).reduce((a, b) => a + b) /
        _recipes.length;
  }

  Map<String, int> get ingredientUsageCount {
    final map = <String, int>{};
    for (final r in _recipes) {
      for (final ing in r.ingredients) {
        map[ing.name] = (map[ing.name] ?? 0) + 1;
      }
    }
    return map;
  }

  int get weeklyMealsCount {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return mealsForWeek(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)).length;
  }

  // ─── Sample data ──────────────────────────────────────────────────────────
  List<Recipe> _sampleRecipes() => [
        Recipe(
          id: _uuid.v4(),
          name: 'Pasta al Pomodoro',
          description:
              'Cuoci la pasta in abbondante acqua salata. In una padella soffriggi l\'aglio nell\'olio, aggiungi i pomodori pelati e cuoci per 15 min. Scola la pasta e manteca con il sugo.',
          category: 'Primo',
          prepTimeMinutes: 25,
          difficulty: 'Facile',
          servings: 4,
          ingredients: [
            RecipeIngredient(name: 'Pasta', quantity: 400, unit: 'g'),
            RecipeIngredient(name: 'Pomodori pelati', quantity: 400, unit: 'g'),
            RecipeIngredient(name: 'Aglio', quantity: 2, unit: 'pz'),
            RecipeIngredient(name: 'Olio d\'oliva', quantity: 3, unit: 'cucchiai'),
            RecipeIngredient(name: 'Sale', quantity: 1, unit: 'q.b.'),
            RecipeIngredient(name: 'Basilico', quantity: 5, unit: 'pz'),
          ],
          notes: 'Aggiungere parmigiano a piacere.',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Recipe(
          id: _uuid.v4(),
          name: 'Uova Strapazzate',
          description:
              'Sbatti le uova con sale e pepe. Scalda il burro in padella a fuoco basso, aggiungi le uova e mescola continuamente fino a cottura cremosa.',
          category: 'Colazione',
          prepTimeMinutes: 10,
          difficulty: 'Facile',
          servings: 2,
          ingredients: [
            RecipeIngredient(name: 'Uova', quantity: 4, unit: 'pz'),
            RecipeIngredient(name: 'Burro', quantity: 20, unit: 'g'),
            RecipeIngredient(name: 'Sale', quantity: 1, unit: 'q.b.'),
            RecipeIngredient(name: 'Pepe', quantity: 1, unit: 'q.b.'),
          ],
          notes: 'Servire calde con pane tostato.',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Recipe(
          id: _uuid.v4(),
          name: 'Insalata Greca',
          description:
              'Taglia pomodori, cetriolo, peperone e cipolla. Aggiungi olive e feta sbriciolata. Condisci con olio, origano e sale.',
          category: 'Contorno',
          prepTimeMinutes: 15,
          difficulty: 'Facile',
          servings: 2,
          ingredients: [
            RecipeIngredient(name: 'Pomodori', quantity: 300, unit: 'g'),
            RecipeIngredient(name: 'Cetriolo', quantity: 1, unit: 'pz'),
            RecipeIngredient(name: 'Feta', quantity: 150, unit: 'g'),
            RecipeIngredient(name: 'Olive nere', quantity: 50, unit: 'g'),
            RecipeIngredient(name: 'Cipolla rossa', quantity: 1, unit: 'pz'),
            RecipeIngredient(name: 'Olio d\'oliva', quantity: 2, unit: 'cucchiai'),
          ],
          notes: '',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  List<PantryItem> _samplePantry() {
    final now = DateTime.now();
    return [
      PantryItem(
        id: _uuid.v4(),
        name: 'Pasta',
        category: 'Cereali e Pasta',
        quantity: 500,
        unit: 'g',
        notes: '',
      ),
      PantryItem(
        id: _uuid.v4(),
        name: 'Olio d\'oliva',
        category: 'Condimenti',
        quantity: 500,
        unit: 'ml',
        notes: '',
      ),
      PantryItem(
        id: _uuid.v4(),
        name: 'Uova',
        category: 'Latticini',
        quantity: 6,
        unit: 'pz',
        expiryDate: now.add(const Duration(days: 2)),
        notes: '',
        lowStockThreshold: 2,
      ),
      PantryItem(
        id: _uuid.v4(),
        name: 'Latte',
        category: 'Latticini',
        quantity: 1,
        unit: 'l',
        expiryDate: now.add(const Duration(days: 1)),
        notes: '',
      ),
      PantryItem(
        id: _uuid.v4(),
        name: 'Sale',
        category: 'Condimenti',
        quantity: 500,
        unit: 'g',
        notes: '',
      ),
    ];
  }

  List<MealEntry> _sampleMeals() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      MealEntry(
        id: _uuid.v4(),
        date: today,
        mealType: 'Colazione',
        recipeId: null,
        customLabel: 'Yogurt e frutta',
        notes: '',
      ),
      MealEntry(
        id: _uuid.v4(),
        date: today,
        mealType: 'Pranzo',
        recipeId: null,
        customLabel: 'Pasta al Pomodoro',
        notes: '',
      ),
    ];
  }
}
