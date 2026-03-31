// lib/models/professor.dart
class Professor {
  final int? id;
  final String nome;
  final String disciplina;
  final double valor;
  final String descricao;
  final String contato;
  final String? foto; // Mantém como String? para permitir null
  final bool ativo;

  Professor({
    this.id,
    required this.nome,
    required this.disciplina,
    required this.valor,
    required this.descricao,
    required this.contato,
    this.foto, // Pode ser null
    this.ativo = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'disciplina': disciplina,
    'valor': valor,
    'descricao': descricao,
    'contato': contato,
    'foto': foto, // Pode ser null, SQLite aceita
    'ativo': ativo ? 1 : 0,
  };

  factory Professor.fromMap(Map<String, dynamic> map) => Professor(
    id: map['id'],
    nome: map['nome'],
    disciplina: map['disciplina'],
    valor: map['valor'],
    descricao: map['descricao'],
    contato: map['contato'],
    foto: map['foto'], // Pode ser null do banco
    ativo: map['ativo'] == 1,
  );

  Professor copyWith({
    int? id,
    String? nome,
    String? disciplina,
    double? valor,
    String? descricao,
    String? contato,
    String? foto,
    bool? ativo,
  }) {
    return Professor(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      disciplina: disciplina ?? this.disciplina,
      valor: valor ?? this.valor,
      descricao: descricao ?? this.descricao,
      contato: contato ?? this.contato,
      foto: foto ?? this.foto,
      ativo: ativo ?? this.ativo,
    );
  }
}