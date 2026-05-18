class PantryItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final String notes;
  final double lowStockThreshold;

  PantryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    required this.notes,
    this.lowStockThreshold = 1.0,
  });

  static const List<String> categories = [
    'Frutta e Verdura',
    'Carne e Pesce',
    'Latticini',
    'Cereali e Pasta',
    'Legumi',
    'Condimenti',
    'Spezie',
    'Conserve',
    'Bevande',
    'Altro',
  ];

  static const List<String> units = [
    'g',
    'kg',
    'ml',
    'l',
    'pz',
    'cucchiai',
    'tazze',
    'q.b.',
  ];

  bool get isLowStock => quantity <= lowStockThreshold;

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  bool isExpiringSoonWithin(int days) {
    if (expiryDate == null) return false;
    final diff = daysUntilExpiry!;
    return diff >= 0 && diff <= days;
  }

  bool get isExpiringSoon => isExpiringSoonWithin(3);

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'expiryDate': expiryDate?.toIso8601String(),
        'notes': notes,
        'lowStockThreshold': lowStockThreshold,
      };

  factory PantryItem.fromJson(Map<String, dynamic> json) => PantryItem(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'],
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'])
            : null,
        notes: json['notes'],
        lowStockThreshold: (json['lowStockThreshold'] as num?)?.toDouble() ?? 1.0,
      );

  PantryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    bool clearExpiryDate = false,
    String? notes,
    double? lowStockThreshold,
  }) =>
      PantryItem(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        expiryDate: clearExpiryDate ? null : (expiryDate ?? this.expiryDate),
        notes: notes ?? this.notes,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      );
}
