import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/disciplina.dart';
import 'base_repository.dart';

class DisciplinaRepository extends BaseRepository {
  
  /// Listar todas as disciplinas ativas
  Future<List<Disciplina>> listarTodas({bool apenasAtivas = true}) async {
    try {
      var query = supabase
          .from('disciplinas')
          .select()
          .order('nome');
      
      if (apenasAtivas) {
        query = query.eq('ativa', true);
      }
      
      final response = await query;
      
      return response.map((json) => Disciplina.fromJson(json)).toList();
    } catch (e) {
      logError('listarTodas', e);
      return [];
    }
  }
  
  /// Buscar disciplina por ID
  Future<Disciplina?> buscarPorId(String id) async {
    try {
      final response = await supabase
          .from('disciplinas')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Disciplina.fromJson(response);
    } catch (e) {
      logError('buscarPorId', e);
      return null;
    }
  }
  
  /// Buscar disciplinas por IDs
  Future<List<Disciplina>> buscarPorIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    try {
      final response = await supabase
          .from('disciplinas')
          .select()
          .inFilter('id', ids)
          .order('nome');
      
      return response.map((json) => Disciplina.fromJson(json)).toList();
    } catch (e) {
      logError('buscarPorIds', e);
      return [];
    }
  }
  
  /// Criar nova disciplina (admin)
  Future<Disciplina> criar(Disciplina disciplina) async {
    try {
      final data = disciplina.toJson();
      data.remove('id');
      data['ativa'] = true;
      
      final response = await supabase
          .from('disciplinas')
          .insert(data)
          .select()
          .single();
      
      logSuccess('criar');
      return Disciplina.fromJson(response);
    } catch (e) {
      logError('criar', e);
      rethrow;
    }
  }
  
  /// Atualizar disciplina (admin)
  Future<void> atualizar(String id, Map<String, dynamic> dados) async {
    try {
      dados['updated_at'] = DateTime.now().toIso8601String();
      
      await supabase
          .from('disciplinas')
          .update(dados)
          .eq('id', id);
      
      logSuccess('atualizar');
    } catch (e) {
      logError('atualizar', e);
      rethrow;
    }
  }
  
  /// Ativar/desativar disciplina (admin)
  Future<void> ativarDesativar(String id, bool ativa) async {
    await atualizar(id, {'ativa': ativa});
  }
  
  /// Deletar disciplina (admin)
  Future<void> deletar(String id) async {
    try {
      await supabase
          .from('disciplinas')
          .delete()
          .eq('id', id);
      
      logSuccess('deletar');
    } catch (e) {
      logError('deletar', e);
      rethrow;
    }
  }
}