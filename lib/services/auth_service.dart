import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/usuario.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<Usuario?> login(String email, String senha) async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select()
          .eq('email', email)
          .eq('senha', senha)
          .maybeSingle();

      if (response == null) return null;
      return Usuario.fromJson(response);
    } catch (e) {
      print('❌ Erro no login: $e');
      rethrow;
    }
  }

  Future<Usuario> cadastrarCompleto({
    required String email,
    required String senha,
    required String nome,
    required String tipo,
  }) async {
    final response = await _supabase
        .from('usuarios')
        .insert({'email': email, 'senha': senha, 'nome': nome, 'tipo': tipo})
        .select()
        .single();

    final usuario = Usuario.fromJson(response);

    if (tipo == 'professor') {
      await _supabase.from('professores').insert({
        'usuario_id': usuario.id,
        'materias': [],
        'tipo_aula': 'ambos',
      });
    } else if (tipo == 'aluno') {
      await _supabase.from('alunos').insert({
        'usuario_id': usuario.id,
      });
    }

    return usuario;
  }
}
