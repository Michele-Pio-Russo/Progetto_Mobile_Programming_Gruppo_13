class ListaSpesa {
  // Attributi classe lista spesa
  final String id;
  final String nome;
  final double quantita;
  final String unita;
  final bool comprato; 

  // Costruttore
  ListaSpesa({
    required this.id,
    required this.nome,
    required this.quantita,
    required this.unita,
    this.comprato = false,
  });
} 