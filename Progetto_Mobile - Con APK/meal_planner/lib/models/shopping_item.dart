class ShoppingItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final bool isPurchased;
  final String? sourceRecipeId; // se generato automaticamente da una ricetta
  final String notes;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.isPurchased,
    this.sourceRecipeId,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'isPurchased': isPurchased,
        'sourceRecipeId': sourceRecipeId,
        'notes': notes,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'],
        name: json['name'],
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'],
        isPurchased: json['isPurchased'] ?? false,
        sourceRecipeId: json['sourceRecipeId'],
        notes: json['notes'] ?? '',
      );

  ShoppingItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    bool? isPurchased,
    String? sourceRecipeId,
    bool clearSourceRecipeId = false,
    String? notes,
  }) =>
      ShoppingItem(
        id: id ?? this.id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        isPurchased: isPurchased ?? this.isPurchased,
        sourceRecipeId: clearSourceRecipeId
            ? null
            : (sourceRecipeId ?? this.sourceRecipeId),
        notes: notes ?? this.notes,
      );
}
