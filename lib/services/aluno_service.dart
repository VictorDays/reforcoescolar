import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AlunoService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Buscar perfil do aluno por ID do usuário
  Future<Map<String, dynamic>?> buscarPorUsuarioId(String usuarioId) async {
    try {
      final response = await _supabase
          .from('alunos')
          .select('*, usuarios(*)')
          .eq('usuario_id', usuarioId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Erro ao buscar aluno: $e');
      return null;
    }
  }

  /// Buscar aluno por ID
  Future<Map<String, dynamic>?> buscarPorId(String id) async {
    try {
      final response = await _supabase
          .from('alunos')
          .select('*, usuarios(*)')
          .eq('id', id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Erro ao buscar aluno: $e');
      return null;
    }
  }

  /// Criar perfil de aluno
  Future<Map<String, dynamic>> criar(String usuarioId, {String? serie, String? escola}) async {
    final response = await _supabase
        .from('alunos')
        .insert({
          'usuario_id': usuarioId,
          'serie': serie,
          'escola': escola,
          'interesses': [],
        })
        .select()
        .single();

    return response;
  }

  /// Atualizar perfil do aluno
  Future<void> atualizar(String alunoId, Map<String, dynamic> dados) async {
    final result = await _supabase
        .from('alunos')
        .update(dados)
        .eq('id', alunoId)
        .select();

    if (result.isEmpty) {
      throw Exception('Nenhuma linha atualizada — verifique as permissões do banco (RLS).');
    }
  }

  /// Listar todos os alunos
  Future<List<Map<String, dynamic>>> listarTodos() async {
    final response = await _supabase
        .from('alunos')
        .select('*, usuarios(*)')
        .order('created_at', ascending: false);

    return response;
  }

  /// Deletar aluno
  Future<void> deletar(String id) async {
    await _supabase.from('alunos').delete().eq('id', id);
  }
}