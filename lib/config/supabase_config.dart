import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    print('✅ Supabase conectado!');
  }

  // Nomes das tabelas
  static const String tableUsuarios = 'usuarios';
  static const String tableProfessores = 'professores';
  static const String tableAlunos = 'alunos';
  static const String tableDisciplinas = 'disciplinas';
  static const String tableFavoritos = 'favoritos';
  static const String tableSolicitacoes = 'solicitacoes';
  static const String tableAulas = 'aulas';
  static const String tableAvaliacoes = 'avaliacoes';
  static const String tableNotificacoes = 'notificacoes';
}