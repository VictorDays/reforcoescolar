// lib/modelos/professor.dart
class Professor {
  final int? id;
  final String nome;
  final String disciplina;
  final double valor;
  final String descricao;
  final String contato;
  final String? foto;  // caminho da foto ou base64
  final bool ativo;

  Professor({
    this.id,
    required this.nome,
    required this.disciplina,
    required this.valor,
    required this.descricao,
    required this.contato,
    this.foto,
    this.ativo = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'disciplina': disciplina,
    'valor': valor,
    'descricao': descricao,
    'contato': contato,
    'foto': foto,
    'ativo': ativo ? 1 : 0,
  };

  factory Professor.fromMap(Map<String, dynamic> map) => Professor(
    id: map['id'],
    nome: map['nome'],
    disciplina: map['disciplina'],
    valor: map['valor'],
    descricao: map['descricao'],
    contato: map['contato'],
    foto: map['foto'],
    ativo: map['ativo'] == 1,
  );
}