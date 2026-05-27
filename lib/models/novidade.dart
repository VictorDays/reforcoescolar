import 'package:flutter/material.dart';

class Novidade {
  final String id;
  final String titulo;
  final String descricao;
  final String? imagemUrl;
  final int corHex;
  final bool ativa;
  final DateTime createdAt;

  Novidade({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.imagemUrl,
    this.corHex = 0xFF5C6BC0,
    this.ativa = true,
    required this.createdAt,
  });

  Color get cor => Color(corHex);

  factory Novidade.fromJson(Map<String, dynamic> json) {
    return Novidade(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      imagemUrl: json['imagem_url'],
      corHex: json['cor_hex'] ?? 0xFF5C6BC0,
      ativa: json['ativa'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'descricao': descricao,
    'imagem_url': imagemUrl,
    'cor_hex': corHex,
    'ativa': ativa,
  };
}
