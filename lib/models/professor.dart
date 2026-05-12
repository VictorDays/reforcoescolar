enum TipoAula {
  presencial,
  remoto,
  ambos,
}

class Professor {
  final String id;
  final String usuarioId;
  final List<String> materias; // IDs das disciplinas
  final String? descricao;
  final double? valorHora;
  final TipoAula tipoAula;
  final double avaliacaoMedia;
  final int totalAvaliacoes;
  final bool calendarioIntegrado;
  final String? googleRefreshToken;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Professor({
    required this.id,
    required this.usuarioId,
    required this.materias,
    this.descricao,
    this.valorHora,
    this.tipoAula = TipoAula.ambos,
    this.avaliacaoMedia = 0,
    this.totalAvaliacoes = 0,
    this.calendarioIntegrado = false,
    this.googleRefreshToken,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'materias': materias,
    'descricao': descricao,
    'valor_hora': valorHora,
    'tipo_aula': tipoAula.name,
    'avaliacao_media': avaliacaoMedia,
    'total_avaliacoes': totalAvaliacoes,
    'calendario_integrado': calendarioIntegrado,
    'google_refresh_token': googleRefreshToken,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory Professor.fromJson(Map<String, dynamic> json) => Professor(
    id: json['id'],
    usuarioId: json['usuario_id'],
    materias: List<String>.from(json['materias'] ?? []),
    descricao: json['descricao'],
    valorHora: json['valor_hora']?.toDouble(),
    tipoAula: TipoAula.values.firstWhere(
      (e) => e.name == (json['tipo_aula'] ?? 'ambos'),
      orElse: () => TipoAula.ambos,
    ),
    avaliacaoMedia: (json['avaliacao_media'] ?? 0).toDouble(),
    totalAvaliacoes: json['total_avaliacoes'] ?? 0,
    calendarioIntegrado: json['calendario_integrado'] ?? false,
    googleRefreshToken: json['google_refresh_token'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : null,
  );
}