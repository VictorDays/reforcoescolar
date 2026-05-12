import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/professor.dart';
import 'base_repository.dart';

class ProfessorRepository extends BaseRepository {
  
  /// Buscar perfil do professor por ID do usuário
  Future<Professor?> buscarPorUsuarioId(String usuarioId) async {
    try {
      final response = await supabase
          .from('professores')
          .select()
          .eq('usuario_id', usuarioId)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Professor.fromJson(response);
    } catch (e) {
      logError('buscarPorUsuarioId', e);
      return null;
    }
  }
  
  /// Buscar perfil do professor por ID
  Future<Professor?> buscarPorId(String id) async {
    try {
      final response = await supabase
          .from('professores')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Professor.fromJson(response);
    } catch (e) {
      logError('buscarPorId', e);
      return null;
    }
  }
  
  /// Buscar professor com dados do usuário (join)
  Future<Map<String, dynamic>?> buscarProfessorCompleto(String professorId) async {
    try {
      final response = await supabase
          .from('professores')
          .select('*, usuarios(*)')
          .eq('id', professorId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      logError('buscarProfessorCompleto', e);
      return null;
    }
  }
  
  /// Listar todos os professores (com dados do usuário)
  Future<List<Map<String, dynamic>>> listarTodosCompletos() async {
    try {
      final response = await supabase
          .from('professores')
          .select('*, usuarios(*)')
          .order('created_at', ascending: false);
      
      return response;
    } catch (e) {
      logError('listarTodosCompletos', e);
      return [];
    }
  }
  
  /// Listar professores por matéria
  Future<List<Map<String, dynamic>>> listarPorMateria(String disciplinaId) async {
    try {
      final response = await supabase
          .from('professores')
          .select('*, usuarios(*)')
          .contains('materias', [disciplinaId]);
      
      return response;
    } catch (e) {
      logError('listarPorMateria', e);
      return [];
    }
  }
  
  /// Criar perfil de professor
  Future<Professor> criar(Professor professor) async {
    try {
      final data = professor.toJson();
      data.remove('id');
      
      final response = await supabase
          .from('professores')
          .insert(data)
          .select()
          .single();
      
      logSuccess('criar');
      return Professor.fromJson(response);
    } catch (e) {
      logError('criar', e);
      rethrow;
    }
  }
  
  /// Atualizar perfil do professor
  Future<void> atualizar(String professorId, Map<String, dynamic> dados) async {
    try {
      dados['updated_at'] = DateTime.now().toIso8601String();
      
      await supabase
          .from('professores')
          .update(dados)
          .eq('id', professorId);
      
      logSuccess('atualizar');
    } catch (e) {
      logError('atualizar', e);
      rethrow;
    }
  }
  
  /// Atualizar avaliação média do professor
  Future<void> atualizarMediaAvaliacao(String professorId) async {
    try {
      // Buscar todas as avaliações do professor
      final avaliacoes = await supabase
          .from('avaliacoes')
          .select('nota')
          .eq('professor_id', professorId);
      
      if (avaliacoes.isEmpty) return;
      
      double soma = 0;
      for (var av in avaliacoes) {
        soma += (av['nota'] as int).toDouble();
      }
      
      final media = soma / avaliacoes.length;
      final total = avaliacoes.length;
      
      await supabase
          .from('professores')
          .update({
            'avaliacao_media': media,
            'total_avaliacoes': total,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', professorId);
      
      logSuccess('atualizarMediaAvaliacao');
    } catch (e) {
      logError('atualizarMediaAvaliacao', e);
    }
  }
  
  /// Salvar token do Google Calendar
  Future<void> salvarGoogleToken(String professorId, String refreshToken) async {
    await atualizar(professorId, {
      'calendario_integrado': true,
      'google_refresh_token': refreshToken,
    });
  }
  
  /// Remover integração com Google Calendar
  Future<void> removerGoogleToken(String professorId) async {
    await atualizar(professorId, {
      'calendario_integrado': false,
      'google_refresh_token': null,
    });
  }
  
  /// Listar todos os professores (admin)
  Future<List<Professor>> listarTodos() async {
    try {
      final response = await supabase
          .from('professores')
          .select()
          .order('created_at', ascending: false);
      
      return response.map((json) => Professor.fromJson(json)).toList();
    } catch (e) {
      logError('listarTodos', e);
      return [];
    }
  }
}