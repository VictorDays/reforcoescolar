class Professor {
  final String id;
  final String usuarioId;
  final List<String> materias;
  final String? descricao;
  final double? valorHora;
  final double avaliacaoMedia;
  final int totalAvaliacoes;
  final String tipoAula;
  final DateTime createdAt;

  Professor({
    required this.id,
    required this.usuarioId,
    required this.materias,
    this.descricao,
    this.valorHora,
    this.avaliacaoMedia = 0,
    this.totalAvaliacoes = 0,
    this.tipoAula = 'ambos',
    required this.createdAt,
  });

  factory Professor.fromJson(Map<String, dynamic> json) {
    return Professor(
      id: json['id'],
      usuarioId: json['usuario_id'],
      materias: List<String>.from(json['materias'] ?? []),
      descricao: json['descricao'],
      valorHora: json['valor_hora']?.toDouble(),
      avaliacaoMedia: (json['avaliacao_media'] ?? 0).toDouble(),
      totalAvaliacoes: json['total_avaliacoes'] ?? 0,
      tipoAula: json['tipo_aula'] ?? 'ambos',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'materias': materias,
      'descricao': descricao,
      'valor_hora': valorHora,
      'avaliacao_media': avaliacaoMedia,
      'total_avaliacoes': totalAvaliacoes,
      'tipo_aula': tipoAula,
      'created_at': createdAt.toIso8601String(),
    };
  }
}