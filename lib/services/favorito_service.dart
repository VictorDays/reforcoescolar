import '../repositories/favorito_repository.dart';

class FavoritoService {
  final FavoritoRepository _favoritoRepository = FavoritoRepository();

  /// Adicionar favorito
  Future<void> adicionar(String alunoId, String professorId) async {
    await _favoritoRepository.adicionar(alunoId, professorId);
  }

  /// Remover favorito
  Future<void> remover(String alunoId, String professorId) async {
    await _favoritoRepository.remover(alunoId, professorId);
  }

  /// Verificar se é favorito
  Future<bool> isFavorito(String alunoId, String professorId) async {
    return await _favoritoRepository.isFavorito(alunoId, professorId);
  }

  /// Listar favoritos do aluno
  Future<List<Map<String, dynamic>>> listarPorAluno(String alunoId) async {
    return await _favoritoRepository.listarCompletosPorAluno(alunoId);
  }

  /// Contar favoritos do professor
  Future<int> contarPorProfessor(String professorId) async {
    return await _favoritoRepository.contarFavoritosDoProfessor(professorId);
  }
}