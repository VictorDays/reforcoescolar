// lib/database/db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modelos/disciplina.dart';
import '../modelos/professor.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    
    _database = await openDatabase(
      join(await getDatabasesPath(), 'reforco_escolar.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE disciplinas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL UNIQUE,
            icone TEXT
          )
        ''');
        
        await db.execute('''
          CREATE TABLE professores(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            disciplina TEXT NOT NULL,
            valor REAL NOT NULL,
            descricao TEXT,
            contato TEXT NOT NULL,
            foto TEXT,
            ativo INTEGER DEFAULT 1
          )
        ''');
        
        // Inserir disciplinas padrão
        await _insertDefaultDisciplinas(db);
      },
      version: 1,
    );
    
    return _database!;
  }
  
  static Future<void> _insertDefaultDisciplinas(Database db) async {
    final disciplinasPadrao = [
      'Matemática', 'Português', 'Física', 'Química', 'História', 'Biologia', 'Inglês'
    ];
    
    for (var nome in disciplinasPadrao) {
      await db.insert('disciplinas', {'nome': nome});
    }
  }

  // ==================== CRUD DISCIPLINAS ====================
  
  static Future<void> insertDisciplina(Disciplina disciplina) async {
    final db = await getDatabase();
    await db.insert(
      'disciplinas',
      disciplina.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<List<Disciplina>> getAllDisciplinas() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'disciplinas',
      orderBy: 'nome',
    );
    return maps.map((map) => Disciplina.fromMap(map)).toList();
  }

  static Future<Disciplina?> getDisciplinaById(int id) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'disciplinas',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Disciplina.fromMap(maps.first);
    }
    return null;
  }

  static Future<Disciplina?> getDisciplinaByNome(String nome) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'disciplinas',
      where: 'nome = ?',
      whereArgs: [nome],
    );
    if (maps.isNotEmpty) {
      return Disciplina.fromMap(maps.first);
    }
    return null;
  }

  static Future<void> updateDisciplina(Disciplina disciplina) async {
    final db = await getDatabase();
    await db.update(
      'disciplinas',
      disciplina.toMap(),
      where: 'id = ?',
      whereArgs: [disciplina.id],
    );
  }

  static Future<void> deleteDisciplina(int id) async {
    final db = await getDatabase();
    await db.delete(
      'disciplinas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== CRUD PROFESSORES ====================
  
  static Future<void> insertProfessor(Professor professor) async {
    final db = await getDatabase();
    await db.insert('professores', {
      'nome': professor.nome,
      'disciplina': professor.disciplina,
      'valor': professor.valor,
      'descricao': professor.descricao,
      'contato': professor.contato,
      'foto': professor.foto,
      'ativo': professor.ativo ? 1 : 0,
    });
  }

  static Future<List<Professor>> getAllProfessores({bool apenasAtivos = true}) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'professores',
      where: apenasAtivos ? 'ativo = 1' : null,
      orderBy: 'nome',
    );
    return maps.map((map) => Professor.fromMap(map)).toList();
  }

  static Future<Professor?> getProfessorById(int id) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'professores',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Professor.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<Professor>> getProfessoresByDisciplina(String disciplina) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'professores',
      where: 'disciplina = ? AND ativo = 1',
      whereArgs: [disciplina],
      orderBy: 'nome',
    );
    return maps.map((map) => Professor.fromMap(map)).toList();
  }

  static Future<void> updateProfessor(Professor professor) async {
    final db = await getDatabase();
    await db.update(
      'professores',
      {
        'nome': professor.nome,
        'disciplina': professor.disciplina,
        'valor': professor.valor,
        'descricao': professor.descricao,
        'contato': professor.contato,
        'foto': professor.foto,
        'ativo': professor.ativo ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [professor.id],
    );
  }

  static Future<void> deleteProfessor(int id) async {
    final db = await getDatabase();
    await db.delete(
      'professores',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  static Future<void> toggleProfessorAtivo(int id, bool ativo) async {
    final db = await getDatabase();
    await db.update(
      'professores',
      {'ativo': ativo ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== MÉTODOS DE BUSCA AVANÇADA ====================
  
  static Future<int> getTotalProfessores() async {
    final db = await getDatabase();
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM professores WHERE ativo = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<int> getTotalDisciplinas() async {
    final db = await getDatabase();
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM disciplinas');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<List<Map<String, dynamic>>> getEstatisticas() async {
    final db = await getDatabase();
    return await db.rawQuery('''
      SELECT 
        d.nome as disciplina,
        COUNT(p.id) as total_professores
      FROM disciplinas d
      LEFT JOIN professores p ON d.nome = p.disciplina AND p.ativo = 1
      GROUP BY d.nome
      ORDER BY total_professores DESC
    ''');
  }
}