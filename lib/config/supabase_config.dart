import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuração central do Supabase
/// 
/// Esta classe gerencia a conexão com o Supabase e fornece
/// acesso ao cliente para todos os repositories.
class SupabaseConfig {
  // Singleton
  static final SupabaseConfig _instance = SupabaseConfig._internal();
  factory SupabaseConfig() => _instance;
  SupabaseConfig._internal();

  // Cliente Supabase (acessado pelos repositories)
  static SupabaseClient get client => Supabase.instance.client;
  
  // URLs e chaves (definidas no main.dart)
  static String? _url;
  static String? _anonKey;
  
  /// Inicializar Supabase (chamado no main.dart)
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    _url = url;
    _anonKey = anonKey;
    
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    
    print('✅ SupabaseConfig: Conectado com sucesso!');
  }
  
  /// Verificar se está conectado
  static bool get isConnected => Supabase.instance.client.auth.currentSession != null;
  
  /// Obter URL do projeto
  static String? get url => _url;
  
  // ============================================
  // NOMES DAS TABELAS (centralizados)
  // ============================================
  
  static const String tableUsuarios = 'usuarios';
  static const String tableDisciplinas = 'disciplinas';
  static const String tableAlunos = 'alunos';
  static const String tableProfessores = 'professores';
  static const String tableFavoritos = 'favoritos';
  static const String tableSolicitacoes = 'solicitacoes';
  static const String tableAulas = 'aulas';
  static const String tableAvaliacoes = 'avaliacoes';
  static const String tableNotificacoes = 'notificacoes';
  
  // ============================================
  // BUCKETS DO STORAGE
  // ============================================
  
  static const String bucketAvatars = 'avatars';
  static const String bucketAulas = 'aulas';
  
  /// Inicializar buckets de storage (executar uma vez)
  static Future<void> initBuckets() async {
    try {
      // Verificar/criar bucket de avatars
      final buckets = await client.storage.listBuckets();
      
      bool hasAvatars = buckets.any((b) => b.name == bucketAvatars);
      if (!hasAvatars) {
        await client.storage.createBucket(bucketAvatars, 
          isPublic: true,
        );
        print('✅ Bucket "$bucketAvatars" criado');
      }
      
      bool hasAulas = buckets.any((b) => b.name == bucketAulas);
      if (!hasAulas) {
        await client.storage.createBucket(bucketAulas,
          isPublic: true,
        );
        print('✅ Bucket "$bucketAulas" criado');
      }
    } catch (e) {
      print('⚠️ Erro ao criar buckets: $e');
    }
  }
  
  // ============================================
  // HELPERS
  // ============================================
  
  /// Gerar URL pública para um arquivo no storage
  static String getPublicUrl(String bucket, String path) {
    return client.storage.from(bucket).getPublicUrl(path);
  }
  
  /// Fazer upload de arquivo
  static Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> bytes,
    String? contentType,
  }) async {
    await client.storage.from(bucket).uploadBinary(
      path,
      bytes,
      fileOptions: contentType != null 
          ? FileOptions(contentType: contentType)
          : null,
    );
    return getPublicUrl(bucket, path);
  }
  
  /// Deletar arquivo
  static Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await client.storage.from(bucket).remove([path]);
  }
}