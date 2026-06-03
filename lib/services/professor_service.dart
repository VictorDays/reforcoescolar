import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class ProfessorService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Buscar perfil do professor por ID do usuário
  Future<Map<String, dynamic>?> buscarPorUsuarioId(String usuarioId) async {
    return await _supabase
        .from('professores')
        .select('*, usuarios(*)')
        .eq('usuario_id', usuarioId)
        .maybeSingle();
  }

  /// Buscar professor por ID
  Future<Map<String, dynamic>?> buscarPorId(String id) async {
    try {
      final response = await _supabase
          .from('professores')
          .select('*, usuarios(*)')
          .eq('id', id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Erro ao buscar professor: $e');
      return null;
    }
  }

  /// Listar todos os professores
  Future<List<Map<String, dynamic>>> listarTodos() async {
    final response = await _supabase
        .from('professores')
        .select('*, usuarios(*)')
        .order('created_at', ascending: false);

    return response;
  }

  /// Listar professores por matéria
  Future<List<Map<String, dynamic>>> listarPorMateria(String materiaId) async {
    final response = await _supabase
        .from('professores')
        .select('*, usuarios(*)')
        .contains('materias', [materiaId]);

    return response;
  }

  /// Criar perfil de professor
  Future<Map<String, dynamic>> criar(
    String usuarioId, {
    required List<String> materias,
    String? descricao,
    double? valorHora,
    String tipoAula = 'ambos',
  }) async {
    final response = await _supabase
        .from('professores')
        .insert({
          'usuario_id': usuarioId,
          'materias': materias,
          'descricao': descricao,
          'valor_hora': valorHora,
          'tipo_aula': tipoAula,
          'avaliacao_media': 0,
          'total_avaliacoes': 0,
        })
        .select()
        .single();

    return response;
  }

  /// Atualizar perfil do professor
  Future<void> atualizar(String professorId, Map<String, dynamic> dados) async {
    final result = await _supabase
        .from('professores')
        .update(dados)
        .eq('id', professorId)
        .select();

    if (result.isEmpty) {
      throw Exception('Nenhuma linha atualizada — verifique as permissões do banco (RLS).');
    }
  }

  /// Deletar professor
  Future<void> deletar(String id) async {
    await _supabase.from('professores').delete().eq('id', id);
  }

  /// Atualizar avaliação média do professor
  Future<void> atualizarMediaAvaliacao(String professorId) async {
    try {
      final avaliacoes = await _supabase
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

      await _supabase
          .from('professores')
          .update({
            'avaliacao_media': media,
            'total_avaliacoes': total,
          })
          .eq('id', professorId);
    } catch (e) {
      print('Erro ao atualizar média: $e');
    }
  }
}