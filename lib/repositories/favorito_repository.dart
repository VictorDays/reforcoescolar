import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/favorito.dart';
import 'base_repository.dart';

class FavoritoRepository extends BaseRepository {
  
  /// Listar favoritos de um aluno
  Future<List<Favorito>> listarPorAluno(String alunoId) async {
    try {
      final response = await supabase
          .from('favoritos')
          .select()
          .eq('aluno_id', alunoId)
          .order('created_at', ascending: false);
      
      return response.map((json) => Favorito.fromJson(json)).toList();
    } catch (e) {
      logError('listarPorAluno', e);
      return [];
    }
  }
  
  /// Listar favoritos de um aluno com dados do professor
  Future<List<Map<String, dynamic>>> listarCompletosPorAluno(String alunoId) async {
    try {
      final response = await supabase
          .from('favoritos')
          .select('*, professores(*, usuarios(*))')
          .eq('aluno_id', alunoId)
          .order('created_at', ascending: false);
      
      return response;
    } catch (e) {
      logError('listarCompletosPorAluno', e);
      return [];
    }
  }
  
  /// Verificar se professor é favorito do aluno
  Future<bool> isFavorito(String alunoId, String professorId) async {
    try {
      final response = await supabase
          .from('favoritos')
          .select('id')
          .eq('aluno_id', alunoId)
          .eq('professor_id', professorId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      logError('isFavorito', e);
      return false;
    }
  }
  
  /// Adicionar favorito
  Future<Favorito> adicionar(String alunoId, String professorId) async {
    try {
      // Verificar se já existe
      final existe = await isFavorito(alunoId, professorId);
      if (existe) {
        throw Exception('Professor já é favorito');
      }
      
      final data = {
        'aluno_id': alunoId,
        'professor_id': professorId,
      };
      
      final response = await supabase
          .from('favoritos')
          .insert(data)
          .select()
          .single();
      
      logSuccess('adicionar');
      return Favorito.fromJson(response);
    } catch (e) {
      logError('adicionar', e);
      rethrow;
    }
  }
  
  /// Remover favorito
  Future<void> remover(String alunoId, String professorId) async {
    try {
      await supabase
          .from('favoritos')
          .delete()
          .eq('aluno_id', alunoId)
          .eq('professor_id', professorId);
      
      logSuccess('remover');
    } catch (e) {
      logError('remover', e);
      rethrow;
    }
  }
  
  /// Contar quantos favoritos um professor tem
  Future<int> contarFavoritosDoProfessor(String professorId) async {
    try {
      final response = await supabase
          .from('favoritos')
          .select('id', count: CountOption.exact)
          .eq('professor_id', professorId);
      
      return response.count ?? 0;
    } catch (e) {
      logError('contarFavoritosDoProfessor', e);
      return 0;
    }
  }
}