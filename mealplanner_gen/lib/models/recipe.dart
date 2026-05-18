import 'dart:convert';

class RecipeIngredient {
  final String name;
  final double quantity;
  final String unit;

  RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
      };

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(
        name: json['name'],
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'],
      );

  RecipeIngredient copyWith({String? name, double? quantity, String? unit}) =>
      RecipeIngredient(
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
      );
}

class Recipe {
  final String id;
  final String name;
  final String description;
  final String category;
  final int prepTimeMinutes;
  final String difficulty;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final String notes;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.prepTimeMinutes,
    required this.difficulty,
    required this.servings,
    required this.ingredients,
    required this.notes,
    required this.createdAt,
  });

  static const List<String> categories = [
    'Colazione',
    'Primo',
    'Secondo',
    'Contorno',
    'Dessert',
    'Snack',
    'Bevanda',
    'Altro',
  ];

  static const List<String> difficulties = ['Facile', 'Media', 'Difficile'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'prepTimeMinutes': prepTimeMinutes,
        'difficulty': difficulty,
        'servings': servings,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        category: json['category'],
        prepTimeMinutes: json['prepTimeMinutes'],
        difficulty: json['difficulty'],
        servings: json['servings'],
        ingredients: (json['ingredients'] as List)
            .map((i) => RecipeIngredient.fromJson(i))
            .toList(),
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? prepTimeMinutes,
    String? difficulty,
    int? servings,
    List<RecipeIngredient>? ingredients,
    String? notes,
    DateTime? createdAt,
  }) =>
      Recipe(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
        difficulty: difficulty ?? this.difficulty,
        servings: servings ?? this.servings,
        ingredients: ingredients ?? this.ingredients,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
}
