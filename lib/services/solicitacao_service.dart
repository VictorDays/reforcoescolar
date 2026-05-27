import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/solicitacao.dart';

class SolicitacaoService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<List<Solicitacao>> listarDoProfessor(String professorId) async {
    final response = await _supabase
        .from('solicitacoes')
        .select('*, alunos(*, usuarios(*))')
        .eq('professor_id', professorId)
        .order('created_at', ascending: false);
    return response.map<Solicitacao>((j) => Solicitacao.fromJson(j)).toList();
  }

  Future<List<Solicitacao>> listarDoAluno(String alunoId) async {
    final response = await _supabase
        .from('solicitacoes')
        .select('*, professores(*, usuarios(*))')
        .eq('aluno_id', alunoId)
        .order('created_at', ascending: false);
    return response.map<Solicitacao>((j) => Solicitacao.fromJson(j)).toList();
  }

  Future<Solicitacao> criar(Map<String, dynamic> dados) async {
    final response = await _supabase
        .from('solicitacoes')
        .insert(dados)
        .select()
        .single();
    return Solicitacao.fromJson(response);
  }

  Future<void> atualizarStatus(String id, String status,
      {Map<String, dynamic>? extra}) async {
    final dados = <String, dynamic>{'status': status};
    if (extra != null) dados.addAll(extra);

    final result = await _supabase
        .from('solicitacoes')
        .update(dados)
        .eq('id', id)
        .select();

    if (result.isEmpty) {
      throw Exception('Nenhuma linha atualizada — verifique as permissões do banco.');
    }
  }

  Future<void> deletar(String id) async {
    await _supabase.from('solicitacoes').delete().eq('id', id);
  }
}
