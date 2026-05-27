import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AdminService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // ========== USUÁRIOS ==========
  Future<List<Map<String, dynamic>>> listarUsuarios() async {
    final response = await _supabase
        .from('usuarios')
        .select()
        .order('created_at', ascending: false);
    return response;
  }

  Future<void> deletarUsuario(String id) async {
    await _supabase.from('usuarios').delete().eq('id', id);
  }

  Future<void> atualizarUsuario(String id, Map<String, dynamic> dados) async {
    await _supabase.from('usuarios').update(dados).eq('id', id);
  }

  // ========== PROFESSORES ==========
  Future<List<Map<String, dynamic>>> listarProfessores() async {
    final response = await _supabase
        .from('professores')
        .select('*, usuarios(*)')
        .order('created_at', ascending: false);
    return response;
  }

  Future<void> deletarProfessor(String id) async {
    await _supabase.from('professores').delete().eq('id', id);
  }

  // ========== ALUNOS ==========
  Future<List<Map<String, dynamic>>> listarAlunos() async {
    final response = await _supabase
        .from('alunos')
        .select('*, usuarios(*)')
        .order('created_at', ascending: false);
    return response;
  }

  Future<void> deletarAluno(String id) async {
    await _supabase.from('alunos').delete().eq('id', id);
  }

  // ========== DISCIPLINAS ==========
  Future<List<Map<String, dynamic>>> listarDisciplinas() async {
    final response = await _supabase
        .from('disciplinas')
        .select()
        .order('nome');
    return response;
  }

  Future<Map<String, dynamic>> criarDisciplina(String nome, String? descricao) async {
    final response = await _supabase
        .from('disciplinas')
        .insert({
          'nome': nome,
          'descricao': descricao,
          'ativa': true,
        })
        .select()
        .single();
    return response;
  }

  Future<void> atualizarDisciplina(String id, Map<String, dynamic> dados) async {
    await _supabase.from('disciplinas').update(dados).eq('id', id);
  }

  Future<void> deletarDisciplina(String id) async {
    await _supabase.from('disciplinas').delete().eq('id', id);
  }
}