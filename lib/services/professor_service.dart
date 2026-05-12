import '../models/professor.dart';
import '../models/disciplina.dart';
import '../repositories/professor_repository.dart';
import '../repositories/disciplina_repository.dart';

class ProfessorService {
  final ProfessorRepository _professorRepository = ProfessorRepository();
  final DisciplinaRepository _disciplinaRepository = DisciplinaRepository();

  /// Buscar todos os professores (com dados do usuário)
  Future<List<Map<String, dynamic>>> listarTodosProfessores() async {
    return await _professorRepository.listarTodosCompletos();
  }

  /// Buscar professores por matéria
  Future<List<Map<String, dynamic>>> buscarProfessoresPorMateria(String disciplinaId) async {
    if (disciplinaId.isEmpty) {
      throw Exception('Selecione uma matéria');
    }
    return await _professorRepository.listarPorMateria(disciplinaId);
  }

  /// Buscar professor por ID
  Future<Professor?> buscarProfessorPorId(String professorId) async {
    if (professorId.isEmpty) {
      throw Exception('ID do professor obrigatório');
    }
    return await _professorRepository.buscarPorId(professorId);
  }

  /// Buscar professor por ID do usuário
  Future<Professor?> buscarProfessorPorUsuarioId(String usuarioId) async {
    if (usuarioId.isEmpty) {
      throw Exception('ID do usuário obrigatório');
    }
    return await _professorRepository.buscarPorUsuarioId(usuarioId);
  }

  /// Atualizar perfil do professor
  Future<void> atualizarPerfil({
    required String professorId,
    List<String>? materias,
    String? descricao,
    double? valorHora,
    String? tipoAula,
  }) async {
    final dados = <String, dynamic>{};
    
    if (materias != null) {
      if (materias.isEmpty) {
        throw Exception('Selecione pelo menos uma matéria');
      }
      dados['materias'] = materias;
    }
    
    if (descricao != null) {
      dados['descricao'] = descricao;
    }
    
    if (valorHora != null) {
      if (valorHora < 0) {
        throw Exception('Valor por hora não pode ser negativo');
      }
      dados['valor_hora'] = valorHora;
    }
    
    if (tipoAula != null) {
      if (!['presencial', 'remoto', 'ambos'].contains(tipoAula)) {
        throw Exception('Tipo de aula inválido');
      }
      dados['tipo_aula'] = tipoAula;
    }
    
    if (dados.isEmpty) {
      throw Exception('Nenhum dado para atualizar');
    }
    
    await _professorRepository.atualizar(professorId, dados);
  }

  /// Obter disciplinas que o professor ensina (com nomes)
  Future<List<Disciplina>> obterDisciplinasDoProfessor(String professorId) async {
    final professor = await _professorRepository.buscarPorId(professorId);
    if (professor == null) {
      throw Exception('Professor não encontrado');
    }
    
    if (professor.materias.isEmpty) {
      return [];
    }
    
    return await _disciplinaRepository.buscarPorIds(professor.materias);
  }

  /// Verificar se professor ensina determinada matéria
  Future<bool> ensinaMateria(String professorId, String disciplinaId) async {
    final professor = await _professorRepository.buscarPorId(professorId);
    if (professor == null) return false;
    return professor.materias.contains(disciplinaId);
  }

  /// Atualizar média de avaliações do professor
  Future<void> atualizarMediaAvaliacoes(String professorId) async {
    await _professorRepository.atualizarMediaAvaliacao(professorId);
  }
}