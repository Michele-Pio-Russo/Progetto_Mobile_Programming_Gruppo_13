class Dispensa {
  // Attributi classe dispensa
  final String id;
  final String nome;
  final String categoria;
  final double quantita;
  final String unita; 
  final DateTime? scadenza; 
  bool statoCritico; 

  // Costruttore
  Dispensa({
    required this.id,
    required this.nome,
    required this.categoria, 
    required this.quantita,
    required this.unita,
    this.scadenza,
    this.statoCritico = false,
  });

  static const List<String> categorie = [
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

  static const List<String> unitaDiMisura = [
    'g',
    'kg',
    'ml',
    'l',
    'pz',
    'cucchiai',
    'tazze',
    'q.b.',
  ];

  // Metodi per convertire da/a JSON (salvataggio locale)
  Map<String, dynamic> aJson() {
    return {
      'id': id,
      'nome': nome,
      'categoria': categoria,
      'quantita': quantita,
      'unita': unita,
      'scadenza': scadenza?.toIso8601String(),
      'statoCritico': statoCritico,
    };
  }

  // Metodo factory per rigenerare l'oggetto partendo da una mappa JSON letta dal database locale
  factory Dispensa.daJson(Map<String, dynamic> json) {
    return Dispensa(
      id: json['id'],
      nome: json['nome'],
      categoria: json['categoria'] ?? 'Altro',
      quantita: json['quantita'].toDouble(),
      unita: json['unita'],
      scadenza: json['scadenza'] != null 
          ? DateTime.parse(json['scadenza']) 
          : null,
      statoCritico: json['statoCritico'] ?? false,
    );
  }

  // Crea una copia esatta dell'oggetto, utile per gestire l'aggiunta di un oggetto alla dispensa
  Dispensa copia({
    String? id,
    String? nome,
    String? categoria, 
    double? quantita,
    String? unita,
    DateTime? scadenza,
    bool svuotaScadenza = false,  // Quando è true, forza la scadenza ad essere null
    bool? statoCritico,
  }) {
    return Dispensa(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria, 
      quantita: quantita ?? this.quantita,
      unita: unita ?? this.unita,
      scadenza: svuotaScadenza ? null : (scadenza ?? this.scadenza),
      statoCritico: statoCritico ?? this.statoCritico,
    );
  }

  // Metodo per aggiornare manualmente lo stato critico
  void controllaStatoCritico() {
    final oggi = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    // Verifica se è scaduto
    final eScaduto = scadenza != null && scadenza!.isBefore(oggi);
    
    // Verifica se scade a breve
    bool scadeABreve = false;
    if (scadenza != null) {
      final differenzaGiorni = scadenza!.difference(oggi).inDays;
      scadeABreve = differenzaGiorni >= 0 && differenzaGiorni <= 3;
    }

    // Verifica se la quantità è esaurita
    final eInEsaurimento = quantita <= 0;

    // L'articolo è critico se si verifica almeno una delle condizioni
    statoCritico = eScaduto || scadeABreve || eInEsaurimento;
  }
}