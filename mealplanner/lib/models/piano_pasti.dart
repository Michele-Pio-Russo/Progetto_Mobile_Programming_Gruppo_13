class PianoPasti {
  // Attributi classe piano pasti
  final String id;
  final String giorno; 
  final String tipologia; 
  final String nomeRicetta; // Sarà il nome della ricetta, se vuoto '-' non verrà visualizzato nulla
  final String idRicetta; // Per ricondursi alla ricetta dal ricettacolo

  // Costruttore
  PianoPasti({
    required this.id,
    required this.giorno,
    required this.tipologia,
    required this.nomeRicetta,
    required this.idRicetta,
  });


  static const List<String> tipologie = [
    'Colazione',
    'Pranzo',
    'Spuntino',
    'Cena',
    'Altro',
  ];

  static const List<String> giorni = [
    'Lunedì',
    'Martedì',
    'Mercoledì',
    'Giovedì',
    'Venerdì',
    'Sabato',
    'Domenica',
  ];

  // Metodo per convertire l'oggetto in JSON (per il salvataggio futuro)
  Map<String, dynamic> aJson() { // Dynamic vuol dire che il valore può essere di qualsiasi tipo
    return {
      'id': id, // Tra gli apici c'è la chiave, mentre a destra c'è il valore
      'giorno': giorno,
      'tipologia': tipologia,
      'nomeRicetta': nomeRicetta,
      'idRicetta': idRicetta,
    };
  }

  // Metodo factory per ricreare e restituire l'oggetto leggendo dal JSON salvato
  factory PianoPasti.daJson(Map<String, dynamic> json) {
    return PianoPasti(
      id: json['id'],
      giorno: json['giorno'],
      tipologia: json['tipologia'],
      nomeRicetta: json['nomeRicetta'],
      idRicetta: json['idRicetta'],
    );
  }
}