import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/aluno.dart';
import 'base_repository.dart';

class AlunoRepository extends BaseRepository {
  
  /// Buscar perfil do aluno por ID do usuário
  Future<Aluno?> buscarPorUsuarioId(String usuarioId) async {
    try {
      final response = await supabase
          .from('alunos')
          .select()
          .eq('usuario_id', usuarioId)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Aluno.fromJson(response);
    } catch (e) {
      logError('buscarPorUsuarioId', e);
      return null;
    }
  }
  
  /// Buscar perfil do aluno por ID
  Future<Aluno?> buscarPorId(String id) async {
    try {
      final response = await supabase
          .from('alunos')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Aluno.fromJson(response);
    } catch (e) {
      logError('buscarPorId', e);
      return null;
    }
  }
  
  /// Criar perfil de aluno
  Future<Aluno> criar(Aluno aluno) async {
    try {
      final data = aluno.toJson();
      data.remove('id');
      
      final response = await supabase
          .from('alunos')
          .insert(data)
          .select()
          .single();
      
      logSuccess('criar');
      return Aluno.fromJson(response);
    } catch (e) {
      logError('criar', e);
      rethrow;
    }
  }
  
  /// Atualizar perfil do aluno
  Future<void> atualizar(String alunoId, Map<String, dynamic> dados) async {
    try {
      dados['updated_at'] = DateTime.now().toIso8601String();
      
      await supabase
          .from('alunos')
          .update(dados)
          .eq('id', alunoId);
      
      logSuccess('atualizar');
    } catch (e) {
      logError('atualizar', e);
      rethrow;
    }
  }
  
  /// Buscar aluno com dados do usuário (join)
  Future<Map<String, dynamic>?> buscarAlunoCompleto(String usuarioId) async {
    try {
      final response = await supabase
          .from('alunos')
          .select('*, usuarios(*)')
          .eq('usuario_id', usuarioId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      logError('buscarAlunoCompleto', e);
      return null;
    }
  }
  
  /// Listar todos os alunos (admin)
  Future<List<Aluno>> listarTodos() async {
    try {
      final response = await supabase
          .from('alunos')
          .select()
          .order('created_at', ascending: false);
      
      return response.map((json) => Aluno.fromJson(json)).toList();
    } catch (e) {
      logError('listarTodos', e);
      return [];
    }
  }
}