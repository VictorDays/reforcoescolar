import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../repositories/usuario_repository.dart';

class UploadService {
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  /// Upload da foto de perfil do usuário
  Future<String?> uploadFotoPerfil(String usuarioId, File imagem) async {
    try {
      // Validar arquivo
      if (!await imagem.exists()) {
        throw Exception('Arquivo não encontrado');
      }

      // Verificar extensão
      final extensao = imagem.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extensao)) {
        throw Exception('Formato não suportado. Use JPG, PNG ou WEBP');
      }

      // Verificar tamanho (máximo 5MB)
      final tamanho = await imagem.length();
      if (tamanho > 5 * 1024 * 1024) {
        throw Exception('Imagem muito grande. Máximo 5MB');
      }

      // Ler arquivo
      final bytes = await imagem.readAsBytes();
      final uint8list = Uint8List.fromList(bytes);
      
      // Nome único para o arquivo
      final fileName = 'perfis/$usuarioId.$extensao';
      
      // Upload para Supabase Storage
      final url = await SupabaseConfig.uploadFile(
        bucket: SupabaseConfig.bucketAvatars,
        path: fileName,
        bytes: uint8list,
        contentType: 'image/$extensao',
      );
      
      // Atualizar URL no banco
      await _usuarioRepository.atualizarFoto(usuarioId, url);
      
      return url;
    } catch (e) {
      print('Erro no upload da foto: $e');
      return null;
    }
  }

  /// Remover foto de perfil
  Future<bool> removerFotoPerfil(String usuarioId, String fotoUrl) async {
    try {
      // Extrair path da URL
      final uri = Uri.parse(fotoUrl);
      final path = uri.pathSegments.last;
      
      // Deletar do storage
      await SupabaseConfig.deleteFile(
        bucket: SupabaseConfig.bucketAvatars,
        path: 'perfis/$path',
      );
      
      // Remover URL do banco
      await _usuarioRepository.atualizarFoto(usuarioId, '');
      
      return true;
    } catch (e) {
      print('Erro ao remover foto: $e');
      return false;
    }
  }
}