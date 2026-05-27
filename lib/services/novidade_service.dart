import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/novidade.dart';

class NovideService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<List<Novidade>> listarAtivas() async {
    final response = await _supabase
        .from('novidades')
        .select()
        .eq('ativa', true)
        .order('created_at', ascending: false);
    return response.map<Novidade>((j) => Novidade.fromJson(j)).toList();
  }

  Future<List<Novidade>> listarTodas() async {
    final response = await _supabase
        .from('novidades')
        .select()
        .order('created_at', ascending: false);
    return response.map<Novidade>((j) => Novidade.fromJson(j)).toList();
  }

  Future<Novidade> criar(Map<String, dynamic> dados) async {
    final response = await _supabase
        .from('novidades')
        .insert(dados)
        .select()
        .single();
    return Novidade.fromJson(response);
  }

  Future<void> atualizar(String id, Map<String, dynamic> dados) async {
    await _supabase.from('novidades').update(dados).eq('id', id);
  }

  Future<void> deletar(String id) async {
    await _supabase.from('novidades').delete().eq('id', id);
  }
}
