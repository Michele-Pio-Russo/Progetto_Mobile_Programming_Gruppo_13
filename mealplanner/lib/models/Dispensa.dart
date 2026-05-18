class Dispensa {
  // attributi classe dispensa
  final String id;
  final String nome;
  final double quantita;
  final String unita; 
  final DateTime scadenza; 
  final bool statoCritico; 

  // costruttore
  Dispensa({
    required this.id,
    required this.nome,
    required this.quantita,
    required this.unita,
    required this.scadenza,
    this.statoCritico = false,
  });
}