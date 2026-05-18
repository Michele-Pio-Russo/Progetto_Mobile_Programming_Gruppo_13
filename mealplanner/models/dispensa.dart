class Dispensa {
  // attributi classe dispensa
  final String id;
  final String name;
  final double quantity;
  final String unit; 
  final DateTime expirationDate; 
  final bool isCritical; 

  // costruttore
  Dispensa({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.expirationDate,
    this.isCritical = false,
  });
}