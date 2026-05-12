import '../models/usuario.dart';
import '../models/aluno.dart';
import '../models/professor.dart';
import '../repositories/usuario_repository.dart';
import '../repositories/aluno_repository.dart';
import '../repositories/professor_repository.dart';

class AuthService {
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  final AlunoRepository _alunoRepository = AlunoRepository();
  final ProfessorRepository _professorRepository = ProfessorRepository();

  /// Login do usuário
  Future<Usuario?> login(String email, String senha) async {
    // Validações básicas
    if (email.isEmpty) throw Exception('Email obrigatório');
    if (senha.isEmpty) throw Exception('Senha obrigatória');
    if (!email.contains('@')) throw Exception('Email inválido');

    final usuario = await _usuarioRepository.login(email, senha);
    
    if (usuario == null) {
      throw Exception('Email ou senha incorretos');
    }
    
    return usuario;
  }

  /// Cadastro de usuário (base)
  Future<Usuario> cadastrar({
    required String email,
    required String senha,
    required String nome,
    required TipoUsuario tipo,
  }) async {
    // Validações
    if (email.isEmpty) throw Exception('Email obrigatório');
    if (senha.length < 6) throw Exception('Senha deve ter no mínimo 6 caracteres');
    if (nome.isEmpty) throw Exception('Nome obrigatório');
    if (!email.contains('@')) throw Exception('Email inválido');

    // Verificar se email já existe
    final emailExiste = await _usuarioRepository.emailExiste(email);
    if (emailExiste) {
      throw Exception('Email já cadastrado');
    }

    // Criar usuário
    final usuario = Usuario(
      id: '',
      email: email,
      nome: nome,
      tipo: tipo,
      createdAt: DateTime.now(),
    );

    return await _usuarioRepository.cadastrar(usuario, senha);
  }

  /// Completar cadastro de aluno (após criar usuário)
  Future<void> completarCadastroAluno({
    required String usuarioId,
    String? serie,
    String? escola,
    List<String>? interesses,
  }) async {
    final aluno = Aluno(
      id: '',
      usuarioId: usuarioId,
      serie: serie,
      escola: escola,
      interesses: interesses ?? [],
      createdAt: DateTime.now(),
    );
    
    await _alunoRepository.criar(aluno);
  }

  /// Completar cadastro de professor (após criar usuário)
  Future<void> completarCadastroProfessor({
    required String usuarioId,
    required List<String> materias,
    String? descricao,
    double? valorHora,
  }) async {
    if (materias.isEmpty) {
      throw Exception('Selecione pelo menos uma matéria');
    }

    final professor = Professor(
      id: '',
      usuarioId: usuarioId,
      materias: materias,
      descricao: descricao,
      valorHora: valorHora,
      createdAt: DateTime.now(),
    );
    
    await _professorRepository.criar(professor);
  }

  /// Logout
  void logout() {
  }
}