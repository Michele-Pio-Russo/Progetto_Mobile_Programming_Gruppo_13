// Attributi della classe ListaSpesa:
class ListaSpesa {
  final String id;
  final String nome;
  final String quantita;
  bool comprato; // Se l'articolo è stato comprato o meno

  // Costruttore della classe ListaSpesa
  ListaSpesa({
    required this.id,
    required this.nome,
    required this.quantita,
    this.comprato = false,
  });

  // Converte l'oggetto in una Map per poterlo salvare come JSON
  Map<String, dynamic> aJson() {
    return {'id': id, 'nome': nome, 'quantita': quantita, 'comprato': comprato};
  }

  factory ListaSpesa.daJson(Map<String, dynamic> json) {
    return ListaSpesa(
      id: json['id'], // prende il valore con chiave 'id' dal JSON
      nome: json['nome'], // prende il valore con chiave 'nome' dal JSON
      quantita: json['quantita'], // prende il valore con chiave 'quantita' dal JSON
      comprato: json['comprato'], // prende il valore con chiave 'comprato' dal JSON
    );
  }
}
