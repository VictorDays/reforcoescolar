class Aluno {
  final String id;
  final String usuarioId;
  final String? serie;
  final String? escola;
  final List<String> interesses;
  final DateTime createdAt;

  Aluno({
    required this.id,
    required this.usuarioId,
    this.serie,
    this.escola,
    this.interesses = const [],
    required this.createdAt,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'],
      usuarioId: json['usuario_id'],
      serie: json['serie'],
      escola: json['escola'],
      interesses: List<String>.from(json['interesses'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'serie': serie,
      'escola': escola,
      'interesses': interesses,
      'created_at': createdAt.toIso8601String(),
    };
  }
}