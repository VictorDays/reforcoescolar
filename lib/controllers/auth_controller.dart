import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Usuario? _usuarioLogado;
  bool _isLoading = false;
  String? _erro;

  Usuario? get usuarioLogado => _usuarioLogado;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  Future<bool> login(String email, String senha) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _usuarioLogado = await _authService.login(email, senha);
      if (_usuarioLogado == null) _erro = 'E-mail ou senha incorretos.';
      return _usuarioLogado != null;
    } catch (e) {
      _erro = 'Erro: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrar({
    required String email,
    required String senha,
    required String nome,
    required String tipo,
  }) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _usuarioLogado = await _authService.cadastrarCompleto(
        email: email,
        senha: senha,
        nome: nome,
        tipo: tipo,
      );
      return true;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('duplicate') || msg.contains('unique')) {
        _erro = 'Este e-mail já está cadastrado.';
      } else {
        _erro = 'Erro ao criar conta. Tente novamente.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _usuarioLogado = null;
    _erro = null;
    notifyListeners();
  }
}
