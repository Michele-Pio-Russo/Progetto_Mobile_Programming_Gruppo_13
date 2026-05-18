class listaSpesa {
  // attributi classe lista spesa
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final bool isBought; 

  // costruttore
  listaSpesa({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.isBought = false,
  });
} 