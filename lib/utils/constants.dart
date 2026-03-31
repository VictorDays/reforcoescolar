// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Reforço Escolar';
  static const String databaseName = 'reforco_escolar.db';
  static const int databaseVersion = 1;
  
  static const List<String> disciplinasPadrao = [
    'Matemática',
    'Português',
    'Física',
    'Química',
    'História',
    'Biologia',
    'Inglês',
  ];
  
  static const List<Color> coresDisciplinas = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
  ];
  
  static IconData getIconForDisciplina(String disciplina) {
    switch (disciplina.toLowerCase()) {
      case 'matemática':
        return Icons.calculate;
      case 'português':
        return Icons.book;
      case 'física':
        return Icons.science;
      case 'química':
        return Icons.ad_units_sharp;
      case 'história':
        return Icons.history;
      case 'biologia':
        return Icons.biotech;
      case 'inglês':
        return Icons.translate;
      default:
        return Icons.category;
    }
  }
}