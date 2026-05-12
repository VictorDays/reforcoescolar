class Aluno {
  final String id;
  final String usuarioId;
  final String? serie;
  final String? escola;
  final List<String> interesses; // IDs das disciplinas
  final DateTime createdAt;
  final DateTime? updatedAt;

  Aluno({
    required this.id,
    required this.usuarioId,
    this.serie,
    this.escola,
    this.interesses = const [],
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'serie': serie,
    'escola': escola,
    'interesses': interesses,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory Aluno.fromJson(Map<String, dynamic> json) => Aluno(
    id: json['id'],
    usuarioId: json['usuario_id'],
    serie: json['serie'],
    escola: json['escola'],
    interesses: List<String>.from(json['interesses'] ?? []),
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : null,
  );
}