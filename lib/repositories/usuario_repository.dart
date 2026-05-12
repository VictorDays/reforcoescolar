import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';
import 'base_repository.dart';

class UsuarioRepository extends BaseRepository {
  
  /// Buscar usuário por email e senha (login)
  Future<Usuario?> login(String email, String senha) async {
    try {
      final response = await supabase
          .from('usuarios')
          .select()
          .eq('email', email)
          .eq('senha', senha) // TODO: usar hash depois
          .maybeSingle();
      
      if (response == null) return null;
      
      logSuccess('login');
      return Usuario.fromJson(response);
    } catch (e) {
      logError('login', e);
      return null;
    }
  }
  
  /// Buscar usuário por ID
  Future<Usuario?> buscarPorId(String id) async {
    try {
      final response = await supabase
          .from('usuarios')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Usuario.fromJson(response);
    } catch (e) {
      logError('buscarPorId', e);
      return null;
    }
  }
  
  /// Buscar usuário por email
  Future<Usuario?> buscarPorEmail(String email) async {
    try {
      final response = await supabase
          .from('usuarios')
          .select()
          .eq('email', email)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Usuario.fromJson(response);
    } catch (e) {
      logError('buscarPorEmail', e);
      return null;
    }
  }
  
  /// Cadastrar novo usuário
  Future<Usuario> cadastrar(Usuario usuario, String senha) async {
    try {
      final data = usuario.toJson();
      data['senha'] = senha;
      data.remove('id'); // Remover ID pois será gerado pelo banco
      
      final response = await supabase
          .from('usuarios')
          .insert(data)
          .select()
          .single();
      
      logSuccess('cadastrar');
      return Usuario.fromJson(response);
    } catch (e) {
      logError('cadastrar', e);
      rethrow;
    }
  }
  
  /// Atualizar dados do usuário
  Future<void> atualizar(String usuarioId, Map<String, dynamic> dados) async {
    try {
      dados['updated_at'] = DateTime.now().toIso8601String();
      
      await supabase
          .from('usuarios')
          .update(dados)
          .eq('id', usuarioId);
      
      logSuccess('atualizar');
    } catch (e) {
      logError('atualizar', e);
      rethrow;
    }
  }
  
  /// Atualizar foto do usuário
  Future<void> atualizarFoto(String usuarioId, String fotoUrl) async {
    await atualizar(usuarioId, {'foto_url': fotoUrl});
  }
  
  /// Listar todos os usuários (admin)
  Future<List<Usuario>> listarTodos({TipoUsuario? tipo}) async {
    try {
      var query = supabase.from('usuarios').select();
      
      if (tipo != null) {
        query = query.eq('tipo', tipo.name);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      return response.map((json) => Usuario.fromJson(json)).toList();
    } catch (e) {
      logError('listarTodos', e);
      return [];
    }
  }
  
  /// Deletar usuário (admin)
  Future<void> deletar(String usuarioId) async {
    try {
      await supabase
          .from('usuarios')
          .delete()
          .eq('id', usuarioId);
      
      logSuccess('deletar');
    } catch (e) {
      logError('deletar', e);
      rethrow;
    }
  }
  
  /// Verificar se email já existe
  Future<bool> emailExiste(String email) async {
    try {
      final response = await supabase
          .from('usuarios')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      logError('emailExiste', e);
      return false;
    }
  }
}