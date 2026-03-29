import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modelos/disciplina.dart';
import '../modelos/professor.dart';

class DBHelper {
  static Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'reforco.db'),
      onCreate: (db, v) async {
        await db.execute('CREATE TABLE disciplinas(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT)');
        await db.execute('CREATE TABLE professores(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, disciplina TEXT, valor REAL, descricao TEXT, contato TEXT, foto TEXT)');
      },
      version: 1,
    );
  }

  // Métodos CRUD para Disciplinas
  static Future<void> insertDisciplina(Disciplina d) async {
    final db = await getDatabase();
    await db.insert('disciplinas', d.toMap());
  }

  static Future<List<Disciplina>> getDisciplinas() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('disciplinas');
    return maps.map((m) => Disciplina.fromMap(m)).toList();
  }

  // Métodos CRUD para Professores/Anúncios
  static Future<void> insertProfessor(Professor p) async {
    final db = await getDatabase();
    await db.insert('professores', p.toMap());
  }

  static Future<List<Professor>> getProfessores() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('professores');
    return maps.map((m) => Professor.fromMap(m)).toList();
  }
}