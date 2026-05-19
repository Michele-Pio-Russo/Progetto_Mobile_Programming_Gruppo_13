class Ricette {
  // Attributi classe ricetta
  final String id;
  final String titolo;
  final String descrizione;
  final List<String> ingredienti;
  final String categoria; 

  // Costruttore
  Ricette({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.ingredienti,
    required this.categoria,
  });
}