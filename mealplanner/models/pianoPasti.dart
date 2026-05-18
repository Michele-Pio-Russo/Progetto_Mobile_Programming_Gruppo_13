class pianoPasti {
  final String id;
  final String dayOfWeek; // Es. "Lunedì"
  final String mealType;  // Es. "Pranzo" o "Cena"
  final String recipeId;  // Il collegamento rapido alla ricetta richiesto dall'SRS

  pianoPasti({
    required this.id,
    required this.dayOfWeek,
    required this.mealType,
    required this.recipeId,
  });
}