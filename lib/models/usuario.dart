enum TipoUsuario { aluno, admin }

class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String senha;
  final TipoUsuario tipo;
  final bool isLoggedIn;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.tipo,
    this.isLoggedIn = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'email': email,
    'senha': senha,
    'tipo': tipo == TipoUsuario.admin ? 'admin' : 'aluno',
    'isLoggedIn': isLoggedIn ? 1 : 0,
  };

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
    id: map['id'],
    nome: map['nome'],
    email: map['email'],
    senha: map['senha'],
    tipo: map['tipo'] == 'admin' ? TipoUsuario.admin : TipoUsuario.aluno,
    isLoggedIn: map['isLoggedIn'] == 1,
  );
}