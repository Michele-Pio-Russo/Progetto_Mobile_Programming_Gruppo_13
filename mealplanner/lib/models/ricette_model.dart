// Classe di supporto per gestire gli ingredienti in modo strutturato
class Ingrediente {
  final String nome; // Nome dell'ingrediente (es. Farina)
  final String quantita; // Quantità numerica (salvata come stringa)
  final String unitaMisura; // Unità di misura (es. g, ml, pz)

  // Costruttore
  Ingrediente({
    required this.nome,
    required this.quantita,
    required this.unitaMisura,
  });

  // Metodo per convertire l'ingrediente in JSON per il salvataggio
  Map<String, dynamic> aJson() {
    return {
      'nome': nome,
      'quantita': quantita,
      'unitaMisura': unitaMisura,
    };
  }

  // Metodo factory per ricreare l'ingrediente leggendo dal JSON salvato
  factory Ingrediente.daJson(Map<String, dynamic> json) {
    return Ingrediente(
      nome: json['nome'] ?? '',
      quantita: json['quantita'] ?? '',
      unitaMisura: json['unitaMisura'] ?? '',
    );
  }
}

// Classe principale che rappresenta una singola ricetta
class Ricette {
  // Attributi classe ricetta
  final String id; // Identificativo univoco della ricetta
  final String titolo; // Nome della ricetta
  final String preparazione; // Il procedimento passo-passo
  final List<Ingrediente> ingredienti; // Lista degli ingredienti strutturati
  final String categoria; // Es. Primo Piatto, Dolce, ecc.
  final String tempoPreparazione; // Tempo richiesto in minuti (salvato testualmente)
  final int difficolta; // Valore da 1 a 5 fiammelle
  final String quantita; // Numero di porzioni o quantità prodotta (es. '4 persone')
  final String note; // Consigli aggiuntivi o varianti
  final bool isPredefinita; // Vero se è una ricetta di default fornita dall'app

  // Costruttore per creare un nuovo oggetto Ricette
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
      // Mappiamo la lista degli oggetti Ingrediente convertendoli uno a uno in formato dizionario JSON
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
    int diffParsed = 1; // Valore di default in caso mancasse
    var diffRaw = json['difficolta'];
    if (diffRaw != null) {
      if (diffRaw is int) {
        // Se è già un numero, lo usiamo direttamente
        diffParsed = diffRaw;
      } else if (diffRaw is String) {
        // Se è una stringa (es. vecchi dati salvati), la mappiamo al numero corrispondente di fiammelle
        if (diffRaw == 'Facile') diffParsed = 1;
        else if (diffRaw == 'Media') diffParsed = 3;
        else if (diffRaw == 'Difficile') diffParsed = 5;
        else diffParsed = int.tryParse(diffRaw) ?? 1; // Tentativo di conversione finale
      }
    }

    // Convertiamo gli ingredienti
    List<Ingrediente> ingredientiParsati = [];
    if (json['ingredienti'] != null) {
      for (var ing in json['ingredienti']) {
        if (ing is String) {
          // Retrocompatibilità: se i vecchi dati erano stringhe testuali
          ingredientiParsati.add(Ingrediente(nome: ing, quantita: '', unitaMisura: ''));
        } else if (ing is Map<String, dynamic>) {
          ingredientiParsati.add(Ingrediente.daJson(ing)); // Dati nuovi strutturati
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
