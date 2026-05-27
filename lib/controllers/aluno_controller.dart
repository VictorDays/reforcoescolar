import 'package:flutter/material.dart';
import '../services/aluno_service.dart';

class AlunoController extends ChangeNotifier {
  final AlunoService _alunoService = AlunoService();

  Map<String, dynamic>? _alunoAtual;
  bool _isLoading = false;
  String? _erro;

  Map<String, dynamic>? get alunoAtual => _alunoAtual;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  /// Carregar perfil do aluno (cria o registro se não existir)
  Future<void> carregarPerfil(String usuarioId) async {
    if (usuarioId.isEmpty) return;

    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _alunoAtual = await _alunoService.buscarPorUsuarioId(usuarioId);
      _alunoAtual ??= await _alunoService.criar(usuarioId);
    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualizar perfil do aluno
  Future<bool> atualizarPerfil({
    required String alunoId,
    String? serie,
    String? escola,
    List<String>? interesses,
  }) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      final dados = <String, dynamic>{
        'serie': serie ?? '',
        'escola': escola ?? '',
      };
      if (interesses != null) dados['interesses'] = interesses;

      await _alunoService.atualizar(alunoId, dados);
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpar dados
  void limpar() {
    _alunoAtual = null;
    _isLoading = false;
    _erro = null;
    notifyListeners();
  }
}