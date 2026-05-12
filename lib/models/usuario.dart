enum TipoUsuario {
  aluno,
  professor,
  admin,
}

class Usuario {
  final String id;
  final String email;
  final String nome;
  final String? fotoUrl;
  final TipoUsuario tipo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Usuario({
    required this.id,
    required this.email,
    required this.nome,
    this.fotoUrl,
    required this.tipo,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nome': nome,
    'foto_url': fotoUrl,
    'tipo': tipo.name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'],
    email: json['email'],
    nome: json['nome'],
    fotoUrl: json['foto_url'],
    tipo: TipoUsuario.values.firstWhere((e) => e.name == json['tipo']),
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : null,
  );
}