import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      inMemoryDatabasePath, // Use in-memory database
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE transacao(id INTEGER PRIMARY KEY, descricao TEXT, descricao2 TEXT, valor REAL, dt_transacao TEXT)',
        );
      },
    );
  }

  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    await db.insert(
      'transacao',
      transaction,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('transacao');
  }

  Future<Map<String, dynamic>> getSummary(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT
      COUNT(*) as transactionCount,
      SUM(CASE WHEN valor > 0 THEN valor ELSE 0 END) as gains,
      SUM(CASE WHEN valor < 0 THEN valor ELSE 0 END) as spends
    FROM transacao
    WHERE dt_transacao BETWEEN ? AND ?
  ''', [start.toIso8601String(), end.toIso8601String()]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {
        'transactionCount': 0,
        'gains': 0.0,
        'spends': 0.0,
      };
    }
  }
}
