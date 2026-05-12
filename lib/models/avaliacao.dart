class Avaliacao {
  final String id;
  final String aulaId;
  final String alunoId;
  final String professorId;
  final int nota; // 1 a 5
  final String? comentario;
  final DateTime createdAt;

  Avaliacao({
    required this.id,
    required this.aulaId,
    required this.alunoId,
    required this.professorId,
    required this.nota,
    this.comentario,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'aula_id': aulaId,
    'aluno_id': alunoId,
    'professor_id': professorId,
    'nota': nota,
    'comentario': comentario,
    'created_at': createdAt.toIso8601String(),
  };

  factory Avaliacao.fromJson(Map<String, dynamic> json) => Avaliacao(
    id: json['id'],
    aulaId: json['aula_id'],
    alunoId: json['aluno_id'],
    professorId: json['professor_id'],
    nota: json['nota'],
    comentario: json['comentario'],
    createdAt: DateTime.parse(json['created_at']),
  );
}