class Disciplina {
  final int? id;
  final String nome;

  Disciplina({this.id, required this.nome});

  Map<String, dynamic> toMap() => {'id': id, 'nome': nome};
  factory Disciplina.fromMap(Map<String, dynamic> map) => Disciplina(id: map['id'], nome: map['nome']);
}