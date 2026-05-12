import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuração central do Supabase
class SupabaseConfig {
  // Cliente Supabase
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Inicializar Supabase
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    print('✅ SupabaseConfig: Conectado!');
  }
  
  static bool get isConnected => Supabase.instance.client.auth.currentSession != null;
  
  // ============================================
  // NOMES DAS TABELAS
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
  // BUCKETS DO STORAGE (já criados manualmente)
  // ============================================
  static const String bucketAvatars = 'avatars';
  static const String bucketAulas = 'aulas';
  
  // ============================================
  // HELPERS DE STORAGE
  // ============================================
  
  /// Obter URL pública de um arquivo
  static String getPublicUrl(String bucket, String path) {
    return client.storage.from(bucket).getPublicUrl(path);
  }
  
  /// Fazer upload de arquivo
  static Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final options = FileOptions(
      contentType: contentType ?? 'application/octet-stream',
    );
    
    await client.storage.from(bucket).uploadBinary(
      path,
      bytes,
      fileOptions: options,
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
  
  // ============================================
  // UTILITÁRIOS
  // ============================================
  
  static String timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  static TimeOfDay stringToTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}