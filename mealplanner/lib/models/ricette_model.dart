class Ricette {
  // Attributi classe ricetta
  final String id;
  final String titolo;
  final String preparazione;
  final List<String> ingredienti;
  final String categoria;

  // Costruttore
  Ricette({
    required this.id,
    required this.titolo,
    required this.preparazione,
    required this.ingredienti,
    required this.categoria,
  });

  // Categorie predefinite delle ricette (simili a quelle della dispensa)
  static const List<String> categorie = [
    'Antipasto',
    'Primo Piatto',
    'Secondo Piatto',
    'Contorno',
    'Dolce',
    'Piatto Unico',
    'Colazione',
    'Spuntino',
    'Bevande',
    'Altro',
  ];

  // Metodo per convertire l'oggetto in JSON (per il salvataggio futuro nel database locale)
  Map<String, dynamic> aJson() {
    return {
      'id': id,
      'titolo': titolo,
      'preparazione': preparazione,
      'ingredienti': ingredienti,
      'categoria': categoria,
    };
  }

  // Metodo factory per ricreare e restituire l'oggetto leggendo dal JSON salvato
  factory Ricette.daJson(Map<String, dynamic> json) {
    return Ricette(
      id: json['id'],
      titolo: json['titolo'],
      preparazione: json['preparazione'] ?? json['descrizione'],
      ingredienti: List<String>.from(json['ingredienti'] ?? []),
      categoria: json['categoria'] ?? 'Altro',
    );
  }

  // Metodo per creare una copia esatta dell'oggetto, utile per la modifica
  Ricette copia({
    String? id,
    String? titolo,
    String? preparazione,
    List<String>? ingredienti,
    String? categoria,
  }) {
    return Ricette(
      id: id ?? this.id,
      titolo: titolo ?? this.titolo,
      preparazione: preparazione ?? this.preparazione,
      ingredienti: ingredienti ?? this.ingredienti,
      categoria: categoria ?? this.categoria,
    );
  }
}
