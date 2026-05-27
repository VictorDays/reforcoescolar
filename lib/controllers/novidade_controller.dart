import 'package:flutter/material.dart';
import '../models/novidade.dart';
import '../services/novidade_service.dart';

class NovidadeController extends ChangeNotifier {
  final NovideService _service = NovideService();

  List<Novidade> _novidades = [];
  bool _isLoading = false;
  String? _erro;

  List<Novidade> get novidades => _novidades;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  Future<void> carregarAtivas() async {
    _setLoading(true);
    try {
      _novidades = await _service.listarAtivas();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> carregarTodas() async {
    _setLoading(true);
    try {
      _novidades = await _service.listarTodas();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> criar(String titulo, String descricao, int corHex) async {
    _setLoading(true);
    try {
      await _service.criar({'titulo': titulo, 'descricao': descricao, 'cor_hex': corHex, 'ativa': true});
      await carregarTodas();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> atualizar(String id, String titulo, String descricao, int corHex, bool ativa) async {
    try {
      await _service.atualizar(id, {'titulo': titulo, 'descricao': descricao, 'cor_hex': corHex, 'ativa': ativa});
      await carregarTodas();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  Future<void> deletar(String id) async {
    try {
      await _service.deletar(id);
      _novidades.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
