import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modelos/disciplina.dart';
import '../modelos/professor.dart';
import '../modelos/usuario.dart';
import '../modelos/favorito.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    
    _database = await openDatabase(
      join(await getDatabasesPath(), 'reforco_escolar.db'),
      onCreate: (db, version) async {
        // Tabela disciplinas
        await db.execute('''
          CREATE TABLE disciplinas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL UNIQUE
          )
        ''');
        
        // Tabela professores
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
        
        // Tabela usuarios
        await db.execute('''
          CREATE TABLE usuarios(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            senha TEXT NOT NULL,
            tipo TEXT NOT NULL,
            isLoggedIn INTEGER DEFAULT 0
          )
        ''');
        
        // Tabela favoritos
        await db.execute('''
          CREATE TABLE favoritos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuarioId INTEGER NOT NULL,
            professorId INTEGER NOT NULL,
            dataAdicionado TEXT NOT NULL,
            FOREIGN KEY(usuarioId) REFERENCES usuarios(id) ON DELETE CASCADE,
            FOREIGN KEY(professorId) REFERENCES professores(id) ON DELETE CASCADE,
            UNIQUE(usuarioId, professorId)
          )
        ''');
        
        // Inserir usuário admin padrão
        await db.insert('usuarios', {
          'nome': 'Administrador',
          'email': 'admin@reforco.com',
          'senha': 'admin123',
          'tipo': 'admin',
          'isLoggedIn': 0,
        });
        
        // Inserir usuário aluno padrão
        await db.insert('usuarios', {
          'nome': 'Aluno Teste',
          'email': 'aluno@teste.com',
          'senha': 'aluno123',
          'tipo': 'aluno',
          'isLoggedIn': 0,
        });
      },
      version: 1,
    );
    
    return _database!;
  }

  // ==================== CRUD USUÁRIOS ====================
  
  static Future<Usuario?> login(String email, String senha) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );
    
    if (maps.isNotEmpty) {
      final usuario = Usuario.fromMap(maps.first);
      // Atualizar status de login
      await db.update(
        'usuarios',
        {'isLoggedIn': 1},
        where: 'id = ?',
        whereArgs: [usuario.id],
      );
      return usuario;
    }
    return null;
  }
  
  static Future<void> logout(int usuarioId) async {
    final db = await getDatabase();
    await db.update(
      'usuarios',
      {'isLoggedIn': 0},
      where: 'id = ?',
      whereArgs: [usuarioId],
    );
  }
  
  static Future<Usuario?> getUsuarioLogado() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'isLoggedIn = 1',
    );
    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }
  
  static Future<List<Usuario>> getAllUsuarios() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('usuarios');
    return maps.map((map) => Usuario.fromMap(map)).toList();
  }
  
  static Future<void> insertUsuario(Usuario usuario) async {
    final db = await getDatabase();
    await db.insert('usuarios', usuario.toMap());
  }

  // ==================== CRUD FAVORITOS ====================
  
  static Future<void> addFavorito(int usuarioId, int professorId) async {
    final db = await getDatabase();
    await db.insert('favoritos', {
      'usuarioId': usuarioId,
      'professorId': professorId,
      'dataAdicionado': DateTime.now().toIso8601String(),
    });
  }
  
  static Future<void> removeFavorito(int usuarioId, int professorId) async {
    final db = await getDatabase();
    await db.delete(
      'favoritos',
      where: 'usuarioId = ? AND professorId = ?',
      whereArgs: [usuarioId, professorId],
    );
  }
  
  static Future<bool> isFavorito(int usuarioId, int professorId) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'favoritos',
      where: 'usuarioId = ? AND professorId = ?',
      whereArgs: [usuarioId, professorId],
    );
    return maps.isNotEmpty;
  }
  
  static Future<List<Professor>> getFavoritosByUsuario(int usuarioId) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.* FROM professores p
      INNER JOIN favoritos f ON p.id = f.professorId
      WHERE f.usuarioId = ? AND p.ativo = 1
      ORDER BY f.dataAdicionado DESC
    ''', [usuarioId]);
    return maps.map((map) => Professor.fromMap(map)).toList();
  }
  
  static Future<int> getTotalFavoritos(int usuarioId) async {
    final db = await getDatabase();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM favoritos WHERE usuarioId = ?',
      [usuarioId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== CRUD DISCIPLINAS ====================
  
  static Future<void> insertDisciplina(Disciplina disciplina) async {
    final db = await getDatabase();
    await db.insert('disciplinas', disciplina.toMap());
  }

  static Future<List<Disciplina>> getAllDisciplinas() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('disciplinas', orderBy: 'nome');
    return maps.map((map) => Disciplina.fromMap(map)).toList();
  }

  static Future<void> updateDisciplina(Disciplina disciplina) async {
    final db = await getDatabase();
    await db.update('disciplinas', disciplina.toMap(), where: 'id = ?', whereArgs: [disciplina.id]);
  }

  static Future<void> deleteDisciplina(int id) async {
    final db = await getDatabase();
    await db.delete('disciplinas', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== CRUD PROFESSORES ====================
  
  static Future<void> insertProfessor(Professor professor) async {
    final db = await getDatabase();
    await db.insert('professores', professor.toMap());
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
    await db.update('professores', professor.toMap(), where: 'id = ?', whereArgs: [professor.id]);
  }

  static Future<void> deleteProfessor(int id) async {
    final db = await getDatabase();
    await db.delete('professores', where: 'id = ?', whereArgs: [id]);
  }
  
  static Future<void> toggleProfessorAtivo(int id, bool ativo) async {
    final db = await getDatabase();
    await db.update('professores', {'ativo': ativo ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }
}