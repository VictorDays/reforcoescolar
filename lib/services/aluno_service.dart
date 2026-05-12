import '../models/aluno.dart';
import '../repositories/aluno_repository.dart';
import '../repositories/favorito_repository.dart';

class AlunoService {
  final AlunoRepository _alunoRepository = AlunoRepository();
  final FavoritoRepository _favoritoRepository = FavoritoRepository();

  /// Buscar aluno por ID do usuário
  Future<Aluno?> buscarAlunoPorUsuarioId(String usuarioId) async {
    if (usuarioId.isEmpty) {
      throw Exception('ID do usuário obrigatório');
    }
    return await _alunoRepository.buscarPorUsuarioId(usuarioId);
  }

  /// Buscar aluno por ID
  Future<Aluno?> buscarAlunoPorId(String alunoId) async {
    if (alunoId.isEmpty) {
      throw Exception('ID do aluno obrigatório');
    }
    return await _alunoRepository.buscarPorId(alunoId);
  }

  /// Atualizar perfil do aluno
  Future<void> atualizarPerfil({
    required String alunoId,
    String? serie,
    String? escola,
    List<String>? interesses,
  }) async {
    final dados = <String, dynamic>{};
    
    if (serie != null) {
      dados['serie'] = serie;
    }
    
    if (escola != null) {
      dados['escola'] = escola;
    }
    
    if (interesses != null) {
      dados['interesses'] = interesses;
    }
    
    if (dados.isEmpty) {
      throw Exception('Nenhum dado para atualizar');
    }
    
    await _alunoRepository.atualizar(alunoId, dados);
  }

  /// Adicionar professor aos favoritos
  Future<void> favoritarProfessor(String alunoId, String professorId) async {
    if (alunoId.isEmpty) throw Exception('ID do aluno obrigatório');
    if (professorId.isEmpty) throw Exception('ID do professor obrigatório');
    
    await _favoritoRepository.adicionar(alunoId, professorId);
  }

  /// Remover professor dos favoritos
  Future<void> desfavoritarProfessor(String alunoId, String professorId) async {
    if (alunoId.isEmpty) throw Exception('ID do aluno obrigatório');
    if (professorId.isEmpty) throw Exception('ID do professor obrigatório');
    
    await _favoritoRepository.remover(alunoId, professorId);
  }

  /// Verificar se professor é favorito
  Future<bool> isProfessorFavorito(String alunoId, String professorId) async {
    if (alunoId.isEmpty || professorId.isEmpty) return false;
    
    return await _favoritoRepository.isFavorito(alunoId, professorId);
  }

  /// Listar professores favoritos do aluno
  Future<List<Map<String, dynamic>>> listarProfessoresFavoritos(String alunoId) async {
    if (alunoId.isEmpty) {
      throw Exception('ID do aluno obrigatório');
    }
    
    return await _favoritoRepository.listarCompletosPorAluno(alunoId);
  }

  /// Buscar aluno com dados do usuário (completo)
  Future<Map<String, dynamic>?> buscarAlunoCompleto(String usuarioId) async {
    if (usuarioId.isEmpty) {
      throw Exception('ID do usuário obrigatório');
    }
    
    return await _alunoRepository.buscarAlunoCompleto(usuarioId);
  }
}