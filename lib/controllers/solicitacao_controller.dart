import 'package:flutter/material.dart';
import '../models/solicitacao.dart';
import '../services/solicitacao_service.dart';

class SolicitacaoController extends ChangeNotifier {
  final SolicitacaoService _service = SolicitacaoService();

  List<Solicitacao> _solicitacoes = [];
  bool _isLoading = false;
  String? _erro;

  List<Solicitacao> get solicitacoes => _solicitacoes;
  List<Solicitacao> get pendentes => _solicitacoes.where((s) => s.isPendente).toList();
  List<Solicitacao> get aprovadas => _solicitacoes.where((s) => s.isAprovada).toList();
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  Future<void> carregarDoProfessor(String professorId) async {
    _setLoading(true);
    try {
      _solicitacoes = await _service.listarDoProfessor(professorId);
    } catch (e) {
      _erro = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> carregarDoAluno(String alunoId) async {
    _setLoading(true);
    try {
      _solicitacoes = await _service.listarDoAluno(alunoId);
    } catch (e) {
      _erro = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> enviarSolicitacao({
    required String alunoId,
    required String professorId,
    String? mensagem,
    String? disciplina,
    DateTime? horario,
  }) async {
    try {
      await _service.criar({
        'aluno_id': alunoId,
        'professor_id': professorId,
        'status': 'pendente',
        'mensagem': mensagem,
        'disciplina': disciplina,
        'horario_solicitado': horario?.toIso8601String(),
      });
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> aprovar(String id,
      {DateTime? dataConfirmada, String? linkAula}) async {
    final extra = <String, dynamic>{};
    if (dataConfirmada != null) extra['data_confirmada'] = dataConfirmada.toIso8601String();
    if (linkAula != null && linkAula.isNotEmpty) extra['link_aula'] = linkAula;
    return _atualizarStatus(id, 'aprovada', extra: extra.isEmpty ? null : extra);
  }

  Future<bool> recusar(String id) => _atualizarStatus(id, 'recusada');

  Future<bool> _atualizarStatus(String id, String status,
      {Map<String, dynamic>? extra}) async {
    try {
      await _service.atualizarStatus(id, status, extra: extra);
      final idx = _solicitacoes.indexWhere((s) => s.id == id);
      if (idx != -1) {
        final old = _solicitacoes[idx];
        _solicitacoes[idx] = Solicitacao(
          id: old.id,
          alunoId: old.alunoId,
          professorId: old.professorId,
          status: status,
          mensagem: old.mensagem,
          disciplina: old.disciplina,
          horarioSolicitado: old.horarioSolicitado,
          dataConfirmada: extra != null && extra['data_confirmada'] != null
              ? DateTime.parse(extra['data_confirmada'])
              : old.dataConfirmada,
          linkAula: extra?['link_aula'] ?? old.linkAula,
          contatoAluno: old.contatoAluno,
          createdAt: old.createdAt,
          alunoData: old.alunoData,
          professorData: old.professorData,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
