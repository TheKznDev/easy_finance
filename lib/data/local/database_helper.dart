import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Nome do arquivo do banco de dados
  static const _databaseName = "FinancasApp.db";
  // Versão do banco de dados. Incremente ao alterar o schema.
  static const _databaseVersion = 1;

  // Nomes das tabelas
  static const tableCategories = 'categories';
  static const tableTransactions = 'transactions';
  static const tableGoals = 'goals';
  static const tableGroups = 'groups';

  // Torna esta classe um singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Única referência ao banco de dados em toda a aplicação
  static Database? _database;

  // Getter para o banco de dados.
  // Se _database for nulo, inicializa.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Abre o banco de dados e o cria se ele não existir.
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onConfigure: _onConfigure);
  }

  // Habilita o suporte a chaves estrangeiras no SQLite.
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Cria as tabelas na primeira vez que o banco é criado.
  Future _onCreate(Database db, int version) async {
    // --- Tabela de Categorias ---
    // Armazena as categorias de transações (Ex: Salário, Lazer, Moradia)
    await db.execute('''
      CREATE TABLE $tableCategories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        iconCodePoint INTEGER,
        color INTEGER
      )
      ''');

    // --- Tabela de Metas ---
    // Armazena as metas financeiras (Ex: Viagem, Carro Novo)
    await db.execute('''
      CREATE TABLE $tableGoals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        targetValue REAL NOT NULL,
        deadline INTEGER NOT NULL
      )
      ''');

    // --- Tabela de Grupos ---
    // Armazena grupos de transações (Ex: Orçamento de Férias)
    await db.execute('''
      CREATE TABLE $tableGroups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        targetValue REAL,
        creationDate INTEGER NOT NULL
      )
      ''');

    // --- Tabela de Transações ---
    // A tabela principal, que se relaciona com as outras.
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id TEXT PRIMARY KEY,
        description TEXT NOT NULL,
        value REAL NOT NULL,
        date INTEGER NOT NULL, -- Armazenado como millisecondsSinceEpoch
        type TEXT NOT NULL CHECK(type IN ('INCOME', 'EXPENSE')), -- Tipo: Receita ou Despesa
        
        -- Chaves Estrangeiras --
        categoryId TEXT,
        goalId TEXT,
        groupId TEXT,

        FOREIGN KEY (categoryId) REFERENCES $tableCategories (id) ON DELETE SET NULL,
        FOREIGN KEY (goalId) REFERENCES $tableGoals (id) ON DELETE SET NULL,
        FOREIGN KEY (groupId) REFERENCES $tableGroups (id) ON DELETE SET NULL
      )
      ''');
  }
}
