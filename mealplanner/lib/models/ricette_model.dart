class Ingrediente {
  final String nome;
  final String quantita;
  final String unitaMisura;

  Ingrediente({
    required this.nome,
    required this.quantita,
    required this.unitaMisura,
  });

  Map<String, dynamic> aJson() {
    return {
      'nome': nome,
      'quantita': quantita,
      'unitaMisura': unitaMisura,
    };
  }

  factory Ingrediente.daJson(Map<String, dynamic> json) {
    return Ingrediente(
      nome: json['nome'] ?? '',
      quantita: json['quantita'] ?? '',
      unitaMisura: json['unitaMisura'] ?? '',
    );
  }
}

class Ricette {
  // Attributi classe ricetta
  final String id;
  final String titolo;
  final String preparazione;
  final List<Ingrediente> ingredienti;
  final String categoria;
  final String tempoPreparazione;
  final int difficolta;
  final String quantita;
  final String note;
  final bool isPredefinita;

  // Costruttore
  Ricette({
    required this.id,
    required this.titolo,
    required this.preparazione,
    required this.ingredienti,
    required this.categoria,
    required this.tempoPreparazione,
    required this.difficolta,
    required this.quantita,
    this.note = '',
    this.isPredefinita = false,
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
      'ingredienti': ingredienti.map((i) => i.aJson()).toList(),
      'categoria': categoria,
      'tempoPreparazione': tempoPreparazione,
      'difficolta': difficolta,
      'quantita': quantita,
      'note': note,
      'isPredefinita': isPredefinita,
    };
  }

  // Metodo factory per ricreare e restituire l'oggetto leggendo dal JSON salvato
  factory Ricette.daJson(Map<String, dynamic> json) {
    int diffParsed = 1;
    var diffRaw = json['difficolta'];
    if (diffRaw != null) {
      if (diffRaw is int) {
        diffParsed = diffRaw;
      } else if (diffRaw is String) {
        if (diffRaw == 'Facile') diffParsed = 1;
        else if (diffRaw == 'Media') diffParsed = 3;
        else if (diffRaw == 'Difficile') diffParsed = 5;
        else diffParsed = int.tryParse(diffRaw) ?? 1;
      }
    }

    List<Ingrediente> ingredientiParsati = [];
    if (json['ingredienti'] != null) {
      for (var ing in json['ingredienti']) {
        if (ing is String) {
          ingredientiParsati.add(Ingrediente(nome: ing, quantita: '', unitaMisura: ''));
        } else if (ing is Map<String, dynamic>) {
          ingredientiParsati.add(Ingrediente.daJson(ing));
        }
      }
    }

    return Ricette(
      id: json['id'],
      titolo: json['titolo'],
      preparazione: json['preparazione'] ?? json['descrizione'] ?? '',
      ingredienti: ingredientiParsati,
      categoria: json['categoria'] ?? 'Altro',
      tempoPreparazione: json['tempoPreparazione'] ?? 'N/D',
      difficolta: diffParsed,
      quantita: json['quantita'] ?? 'N/D',
      note: json['note'] ?? '',
      isPredefinita: json['isPredefinita'] ?? false,
    );
  }

  // Metodo per creare una copia esatta dell'oggetto, utile per la modifica
  Ricette copia({
    String? id,
    String? titolo,
    String? preparazione,
    List<Ingrediente>? ingredienti,
    String? categoria,
    String? tempoPreparazione,
    int? difficolta,
    String? quantita,
    String? note,
    bool? isPredefinita,
  }) {
    return Ricette(
      id: id ?? this.id,
      titolo: titolo ?? this.titolo,
      preparazione: preparazione ?? this.preparazione,
      ingredienti: ingredienti ?? this.ingredienti,
      categoria: categoria ?? this.categoria,
      tempoPreparazione: tempoPreparazione ?? this.tempoPreparazione,
      difficolta: difficolta ?? this.difficolta,
      quantita: quantita ?? this.quantita,
      note: note ?? this.note,
      isPredefinita: isPredefinita ?? this.isPredefinita,
    );
  }
}
