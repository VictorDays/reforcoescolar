enum TipoUsuario {
  aluno,
  professor,
  admin;

  static TipoUsuario fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return TipoUsuario.admin;
      case 'professor':
        return TipoUsuario.professor;
      default:
        return TipoUsuario.aluno;
    }
  }

  String get label {
    switch (this) {
      case TipoUsuario.admin:
        return 'Administrador';
      case TipoUsuario.professor:
        return 'Professor';
      case TipoUsuario.aluno:
        return 'Aluno';
    }
  }

  String get dbValue {
    switch (this) {
      case TipoUsuario.admin:
        return 'admin';
      case TipoUsuario.professor:
        return 'professor';
      case TipoUsuario.aluno:
        return 'aluno';
    }
  }
}

class Usuario {
  final String id;
  final String email;
  final String nome;
  final String? fotoUrl;
  final String tipo; // String vindo do Supabase: 'admin', 'professor', 'aluno'
  final DateTime createdAt;

  Usuario({
    required this.id,
    required this.email,
    required this.nome,
    this.fotoUrl,
    required this.tipo,
    required this.createdAt,
  });

  /// Converte o tipo string para enum
  TipoUsuario get tipoEnum => TipoUsuario.fromString(tipo);

  bool get isAdmin => tipo == 'admin';
  bool get isProfessor => tipo == 'professor';
  bool get isAluno => tipo == 'aluno';

  String get tipoLabel => tipoEnum.label;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      email: json['email'],
      nome: json['nome'],
      fotoUrl: json['foto_url'],
      tipo: json['tipo'] ?? 'aluno',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nome': nome,
      'foto_url': fotoUrl,
      'tipo': tipo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Usuario copyWith({String? nome, String? fotoUrl}) {
    return Usuario(
      id: id,
      email: email,
      nome: nome ?? this.nome,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      tipo: tipo,
      createdAt: createdAt,
    );
  }
}
