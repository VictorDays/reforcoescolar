import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/avaliacao.dart';
import 'base_repository.dart';

class AvaliacaoRepository extends BaseRepository {
  
  /// Criar avaliação
  Future<Avaliacao> criar(Avaliacao avaliacao) async {
    try {
      final data = avaliacao.toJson();
      data.remove('id');
      
      final response = await supabase
          .from('avaliacoes')
          .insert(data)
          .select()
          .single();
      
      logSuccess('criar');
      return Avaliacao.fromJson(response);
    } catch (e) {
      logError('criar', e);
      rethrow;
    }
  }
  
  /// Buscar avaliação por ID
  Future<Avaliacao?> buscarPorId(String id) async {
    try {
      final response = await supabase
          .from('avaliacoes')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Avaliacao.fromJson(response);
    } catch (e) {
      logError('buscarPorId', e);
      return null;
    }
  }
  
  /// Listar avaliações de um professor
  Future<List<Avaliacao>> listarPorProfessor(String professorId) async {
    try {
      final response = await supabase
          .from('avaliacoes')
          .select()
          .eq('professor_id', professorId)
          .order('created_at', ascending: false);
      
      return response.map((json) => Avaliacao.fromJson(json)).toList();
    } catch (e) {
      logError('listarPorProfessor', e);
      return [];
    }
  }
  
  /// Verificar se aluno já avaliou a aula
  Future<bool> jaAvaliou(String aulaId, String alunoId) async {
    try {
      final response = await supabase
          .from('avaliacoes')
          .select('id')
          .eq('aula_id', aulaId)
          .eq('aluno_id', alunoId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      logError('jaAvaliou', e);
      return true;
    }
  }
  
  /// Buscar média do professor
  Future<double> getMediaProfessor(String professorId) async {
    try {
      final response = await supabase
          .from('avaliacoes')
          .select('nota')
          .eq('professor_id', professorId);
      
      if (response.isEmpty) return 0;
      
      double soma = 0;
      for (var av in response) {
        soma += (av['nota'] as int).toDouble();
      }
      
      return soma / response.length;
    } catch (e) {
      logError('getMediaProfessor', e);
      return 0;
    }
  }
}