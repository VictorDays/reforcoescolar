import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Repository base com métodos comuns e logging
abstract class BaseRepository {
  SupabaseClient get supabase => SupabaseConfig.client;
  
  /// Log de erro
  void logError(String method, dynamic error) {
    print('❌ Erro em ${runtimeType.toString()}.$method: $error');
  }
  
  /// Log de sucesso
  void logSuccess(String method) {
    print('✅ ${runtimeType.toString()}.$method concluído');
  }
}