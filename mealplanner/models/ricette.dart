class Ricette {
  // attributi classe ricetta
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final String category; 

  // costruttore
  Ricette({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.category,
  });
}