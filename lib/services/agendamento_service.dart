import 'package:flutter/material.dart';

import '../models/solicitacao.dart';
import '../models/aula.dart';
import '../repositories/solicitacao_repository.dart';
import '../repositories/aula_repository.dart';

class AgendamentoService {
  final SolicitacaoRepository _solicitacaoRepository = SolicitacaoRepository();
  final AulaRepository _aulaRepository = AulaRepository();

  /// Criar solicitação de aula (aluno → professor)
  Future<Solicitacao> criarSolicitacao({
    required String alunoId,
    required String professorId,
    required String disciplinaId,
    String? mensagem,
    DateTime? dataSugerida,
    TimeOfDay? horarioSugerido,
  }) async {
    // Validações
    if (alunoId.isEmpty) throw Exception('ID do aluno obrigatório');
    if (professorId.isEmpty) throw Exception('ID do professor obrigatório');
    if (disciplinaId.isEmpty) throw Exception('Disciplina obrigatória');

    final solicitacao = Solicitacao(
      id: '',
      alunoId: alunoId,
      professorId: professorId,
      disciplinaId: disciplinaId,
      mensagem: mensagem,
      status: SolicitacaoStatus.pendente,
      dataSugerida: dataSugerida,
      horarioSugerido: horarioSugerido,
      createdAt: DateTime.now(),
    );

    return await _solicitacaoRepository.criar(solicitacao);
  }

  /// Listar solicitações pendentes de um professor
  Future<List<Solicitacao>> listarSolicitacoesPendentes(String professorId) async {
    if (professorId.isEmpty) throw Exception('ID do professor obrigatório');
    return await _solicitacaoRepository.listarPendentesPorProfessor(professorId);
  }

  /// Listar todas solicitações de um professor
  Future<List<Solicitacao>> listarSolicitacoesDoProfessor(String professorId) async {
    if (professorId.isEmpty) throw Exception('ID do professor obrigatório');
    return await _solicitacaoRepository.listarPorProfessor(professorId);
  }

  /// Listar solicitações de um aluno
  Future<List<Solicitacao>> listarSolicitacoesDoAluno(String alunoId) async {
    if (alunoId.isEmpty) throw Exception('ID do aluno obrigatório');
    return await _solicitacaoRepository.listarPorAluno(alunoId);
  }

  /// Aceitar solicitação e criar aula
  Future<Aula> aceitarSolicitacao({
    required String solicitacaoId,
    required DateTime data,
    required TimeOfDay horario,
    int duracao = 60,
    String? observacoes,
  }) async {
    // Buscar solicitação
    final solicitacao = await _solicitacaoRepository.buscarPorId(solicitacaoId);
    if (solicitacao == null) {
      throw Exception('Solicitação não encontrada');
    }

    if (solicitacao.status != SolicitacaoStatus.pendente) {
      throw Exception('Solicitação já foi respondida');
    }

    // Verificar disponibilidade do professor
    final temConflito = await _aulaRepository.verificarConflito(
      solicitacao.professorId,
      data,
      horario,
      duracao,
    );

    if (temConflito) {
      throw Exception('Horário indisponível para o professor');
    }

    // Criar aula
    final aula = Aula(
      id: '',
      solicitacaoId: solicitacaoId,
      professorId: solicitacao.professorId,
      alunoId: solicitacao.alunoId,
      disciplinaId: solicitacao.disciplinaId,
      data: data,
      horario: horario,
      duracao: duracao,
      status: AulaStatus.agendada,
      observacoes: observacoes,
      createdAt: DateTime.now(),
    );

    final aulaCriada = await _aulaRepository.criar(aula);

    // Atualizar status da solicitação
    await _solicitacaoRepository.aceitar(solicitacaoId);

    return aulaCriada;
  }

  /// Recusar solicitação
  Future<void> recusarSolicitacao(String solicitacaoId) async {
    final solicitacao = await _solicitacaoRepository.buscarPorId(solicitacaoId);
    if (solicitacao == null) {
      throw Exception('Solicitação não encontrada');
    }

    if (solicitacao.status != SolicitacaoStatus.pendente) {
      throw Exception('Solicitação já foi respondida');
    }

    await _solicitacaoRepository.recusar(solicitacaoId);
  }

  /// Cancelar solicitação (aluno)
  Future<void> cancelarSolicitacao(String solicitacaoId) async {
    final solicitacao = await _solicitacaoRepository.buscarPorId(solicitacaoId);
    if (solicitacao == null) {
      throw Exception('Solicitação não encontrada');
    }

    await _solicitacaoRepository.cancelar(solicitacaoId);
  }

  /// Listar aulas de um professor
  Future<List<Aula>> listarAulasDoProfessor(String professorId) async {
    if (professorId.isEmpty) throw Exception('ID do professor obrigatório');
    return await _aulaRepository.listarPorProfessor(professorId);
  }

  /// Listar aulas de um aluno
  Future<List<Aula>> listarAulasDoAluno(String alunoId) async {
    if (alunoId.isEmpty) throw Exception('ID do aluno obrigatório');
    return await _aulaRepository.listarPorAluno(alunoId);
  }

  /// Listar próximas aulas
  Future<List<Aula>> listarProximasAulas(String usuarioId, String tipo) async {
    if (usuarioId.isEmpty) throw Exception('ID do usuário obrigatório');
    return await _aulaRepository.listarProximas(usuarioId, tipo);
  }

  /// Cancelar aula
  Future<void> cancelarAula(String aulaId, {String? motivo}) async {
    await _aulaRepository.cancelar(aulaId, motivo: motivo);
  }

  /// Concluir aula
  Future<void> concluirAula(String aulaId) async {
    await _aulaRepository.concluir(aulaId);
  }

  /// Buscar aula por ID
  Future<Aula?> buscarAulaPorId(String aulaId) async {
    return await _aulaRepository.buscarPorId(aulaId);
  }
}