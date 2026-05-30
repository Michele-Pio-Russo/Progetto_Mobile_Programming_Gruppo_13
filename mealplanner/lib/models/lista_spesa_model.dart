class ListaSpesa {
  final String id;
  final String nome;
  final String quantita;
  bool comprato;

  ListaSpesa({
    required this.id,
    required this.nome,
    required this.quantita,
    this.comprato = false,
  });

  Map<String, dynamic> aJson() {
    return {'id': id, 'nome': nome, 'quantita': quantita, 'comprato': comprato};
  }

  factory ListaSpesa.daJson(Map<String, dynamic> json) {
    return ListaSpesa(
      id: json['id'],
      nome: json['nome'],
      quantita: json['quantita'],
      comprato: json['comprato'],
    );
  }
}