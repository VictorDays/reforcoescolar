class Disciplina {
  final String id;
  final String nome;
  final String? descricao;
  final String? icone;
  final String? cor;
  final bool ativa;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Disciplina({
    required this.id,
    required this.nome,
    this.descricao,
    this.icone,
    this.cor,
    this.ativa = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'descricao': descricao,
    'icone': icone,
    'cor': cor,
    'ativa': ativa,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory Disciplina.fromJson(Map<String, dynamic> json) => Disciplina(
    id: json['id'],
    nome: json['nome'],
    descricao: json['descricao'],
    icone: json['icone'],
    cor: json['cor'],
    ativa: json['ativa'] ?? true,
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : null,
  );
}