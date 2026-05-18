class MealEntry {
  final String id;
  final DateTime date;
  final String mealType; // colazione, pranzo, cena, spuntino
  final String? recipeId;
  final String customLabel; // per pasti senza ricetta
  final String notes;

  MealEntry({
    required this.id,
    required this.date,
    required this.mealType,
    this.recipeId,
    required this.customLabel,
    required this.notes,
  });

  static const List<String> mealTypes = [
    'Colazione',
    'Pranzo',
    'Cena',
    'Spuntino',
  ];

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mealType': mealType,
        'recipeId': recipeId,
        'customLabel': customLabel,
        'notes': notes,
      };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
        id: json['id'],
        date: DateTime.parse(json['date']),
        mealType: json['mealType'],
        recipeId: json['recipeId'],
        customLabel: json['customLabel'] ?? '',
        notes: json['notes'] ?? '',
      );

  MealEntry copyWith({
    String? id,
    DateTime? date,
    String? mealType,
    String? recipeId,
    bool clearRecipeId = false,
    String? customLabel,
    String? notes,
  }) =>
      MealEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        mealType: mealType ?? this.mealType,
        recipeId: clearRecipeId ? null : (recipeId ?? this.recipeId),
        customLabel: customLabel ?? this.customLabel,
        notes: notes ?? this.notes,
      );
}
