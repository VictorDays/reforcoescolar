import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/solicitacao.dart';
import 'base_repository.dart';

class SolicitacaoRepository extends BaseRepository {
  
  /// Criar nova solicitação
  Future<Solicitacao> criar(Solicitacao solicitacao) async {
    try {
      final data = solicitacao.toJson();
      data.remove('id');
      
      final response = await supabase
          .from('solicitacoes')
          .insert(data)
          .select()
          .single();
      
      logSuccess('criar');
      return Solicitacao.fromJson(response);
    } catch (e) {
      logError('criar', e);
      rethrow;
    }
  }
  
  /// Buscar solicitação por ID
  Future<Solicitacao?> buscarPorId(String id) async {
    try {
      final response = await supabase
          .from('solicitacoes')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Solicitacao.fromJson(response);
    } catch (e) {
      logError('buscarPorId', e);
      return null;
    }
  }
  
  /// Listar solicitações recebidas por um professor
  Future<List<Solicitacao>> listarPorProfessor(String professorId, {SolicitacaoStatus? status}) async {
    try {
      var query = supabase
          .from('solicitacoes')
          .select()
          .eq('professor_id', professorId)
          .order('created_at', ascending: false);
      
      if (status != null) {
        query = query.eq('status', status.name);
      }
      
      final response = await query;
      return response.map((json) => Solicitacao.fromJson(json)).toList();
    } catch (e) {
      logError('listarPorProfessor', e);
      return [];
    }
  }
  
  /// Listar solicitações feitas por um aluno
  Future<List<Solicitacao>> listarPorAluno(String alunoId, {SolicitacaoStatus? status}) async {
    try {
      var query = supabase
          .from('solicitacoes')
          .select()
          .eq('aluno_id', alunoId)
          .order('created_at', ascending: false);
      
      if (status != null) {
        query = query.eq('status', status.name);
      }
      
      final response = await query;
      return response.map((json) => Solicitacao.fromJson(json)).toList();
    } catch (e) {
      logError('listarPorAluno', e);
      return [];
    }
  }
  
  /// Listar solicitações pendentes para professor
  Future<List<Solicitacao>> listarPendentesPorProfessor(String professorId) async {
    return listarPorProfessor(professorId, status: SolicitacaoStatus.pendente);
  }
  
  /// Atualizar status da solicitação
  Future<void> atualizarStatus(String id, SolicitacaoStatus novoStatus) async {
    try {
      await supabase
          .from('solicitacoes')
          .update({
            'status': novoStatus.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
      
      logSuccess('atualizarStatus');
    } catch (e) {
      logError('atualizarStatus', e);
      rethrow;
    }
  }
  
  /// Aceitar solicitação
  Future<void> aceitar(String id) async {
    await atualizarStatus(id, SolicitacaoStatus.aceita);
  }
  
  /// Recusar solicitação
  Future<void> recusar(String id) async {
    await atualizarStatus(id, SolicitacaoStatus.recusada);
  }
  
  /// Cancelar solicitação (aluno)
  Future<void> cancelar(String id) async {
    await atualizarStatus(id, SolicitacaoStatus.cancelada);
  }
  
  /// Buscar solicitação com dados completos (aluno + professor + disciplina)
  Future<Map<String, dynamic>?> buscarCompleta(String id) async {
    try {
      final response = await supabase
          .from('solicitacoes')
          .select('''
            *,
            alunos!inner(usuarios!inner(nome, email, foto_url)),
            professores!inner(usuarios!inner(nome, email, foto_url), materias, valor_hora),
            disciplinas!inner(nome)
          ''')
          .eq('id', id)
          .maybeSingle();
      
      return response;
    } catch (e) {
      logError('buscarCompleta', e);
      return null;
    }
  }
}