class ListaSpesa {
  // Attributi della lista della spesa
  final String id;
  final String nome;
  final String quantita;
  bool comprato;

  // Costruttore
  ListaSpesa({
    required this.id,
    required this.nome,
    required this.quantita,
    this.comprato = false,
  });

  // Metodo per convertire l'oggetto in una mappa JSON 
  Map<String, dynamic> aJson() {
    return {'id': id, 'nome': nome, 'quantita': quantita, 'comprato': comprato};
  }

  // Metodo factory per rigenerare l'oggetto partendo da una mappa JSON 
  factory ListaSpesa.daJson(Map<String, dynamic> json) {
    return ListaSpesa(
      id: json['id'],
      nome: json['nome'],
      quantita: json['quantita'],
      comprato: json['comprato'],
    );
  }
}