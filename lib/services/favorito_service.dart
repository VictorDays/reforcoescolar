import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class FavoritoService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<List<Map<String, dynamic>>> listarFavoritosDoAluno(String alunoId) async {
    final response = await _supabase
        .from('favoritos')
        .select('*, professores(*, usuarios(*))')
        .eq('aluno_id', alunoId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<bool> isFavorito(String alunoId, String professorId) async {
    final response = await _supabase
        .from('favoritos')
        .select('id')
        .eq('aluno_id', alunoId)
        .eq('professor_id', professorId)
        .maybeSingle();
    return response != null;
  }

  Future<void> adicionar(String alunoId, String professorId) async {
    await _supabase.from('favoritos').insert({
      'aluno_id': alunoId,
      'professor_id': professorId,
    });
  }

  Future<void> remover(String alunoId, String professorId) async {
    await _supabase
        .from('favoritos')
        .delete()
        .eq('aluno_id', alunoId)
        .eq('professor_id', professorId);
  }
}
