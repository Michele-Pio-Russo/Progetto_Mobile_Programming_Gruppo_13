class Ricette {
  // attributi classe ricetta
  final String id;
  final String titolo;
  final String descrizione;
  final List<String> ingredienti;
  final String categoria; 

  // costruttore
  Ricette({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.ingredienti,
    required this.categoria,
  });
}