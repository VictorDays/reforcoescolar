class Solicitacao {
  final String id;
  final String alunoId;
  final String professorId;
  final String status; // pendente, aprovada, recusada
  final String? mensagem;
  final String? disciplina;
  final DateTime? horarioSolicitado;
  final DateTime? dataConfirmada;
  final String? linkAula;
  final String? contatoAluno;
  final DateTime createdAt;
  final Map<String, dynamic>? alunoData;
  final Map<String, dynamic>? professorData;

  Solicitacao({
    required this.id,
    required this.alunoId,
    required this.professorId,
    this.status = 'pendente',
    this.mensagem,
    this.disciplina,
    this.horarioSolicitado,
    this.dataConfirmada,
    this.linkAula,
    this.contatoAluno,
    required this.createdAt,
    this.alunoData,
    this.professorData,
  });

  bool get isPendente => status == 'pendente';
  bool get isAprovada => status == 'aprovada';
  bool get isRecusada => status == 'recusada';

  String get nomeAluno {
    if (alunoData == null) return 'Aluno';
    final u = alunoData!['usuarios'] ?? alunoData!;
    return u['nome'] ?? 'Aluno';
  }

  String get emailAluno {
    if (alunoData == null) return '';
    final u = alunoData!['usuarios'] ?? alunoData!;
    return u['email'] ?? '';
  }

  factory Solicitacao.fromJson(Map<String, dynamic> json) {
    return Solicitacao(
      id: json['id'],
      alunoId: json['aluno_id'],
      professorId: json['professor_id'],
      status: json['status'] ?? 'pendente',
      mensagem: json['mensagem'],
      disciplina: json['disciplina'],
      horarioSolicitado: json['horario_solicitado'] != null
          ? DateTime.parse(json['horario_solicitado'])
          : null,
      dataConfirmada: json['data_confirmada'] != null
          ? DateTime.parse(json['data_confirmada'])
          : null,
      linkAula: json['link_aula'],
      contatoAluno: json['contato_aluno'],
      createdAt: DateTime.parse(json['created_at']),
      alunoData: json['alunos'] as Map<String, dynamic>?,
      professorData: json['professores'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'aluno_id': alunoId,
    'professor_id': professorId,
    'status': status,
    'mensagem': mensagem,
    'disciplina': disciplina,
    'horario_solicitado': horarioSolicitado?.toIso8601String(),
  };
}
