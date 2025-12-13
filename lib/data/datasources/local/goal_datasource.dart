import 'package:sqflite/sqflite.dart';
import '../../../models/goal.dart';
import '../../local/database_helper.dart';

class GoalDataSource {
  final dbHelper = DatabaseHelper.instance;

  // Insere uma nova meta.
  Future<int> insert(Goal goal) async {
    try {
      final db = await dbHelper.database;
      return await db.insert(DatabaseHelper.tableGoals, goal.toMap());
    } catch (e) {
      print('Erro ao inserir meta: $e');
      rethrow;
    }
  }

  // Atualiza uma meta existente.
  Future<int> update(Goal goal) async {
    try {
      final db = await dbHelper.database;
      return await db.update(
        DatabaseHelper.tableGoals,
        goal.toMap(),
        where: 'id = ?',
        whereArgs: [goal.id],
      );
    } catch (e) {
      print('Erro ao atualizar meta: $e');
      rethrow;
    }
  }

  // Deleta uma meta pelo seu ID.
  Future<int> delete(String id) async {
    try {
      final db = await dbHelper.database;
      return await db.delete(
        DatabaseHelper.tableGoals,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao deletar meta: $e');
      rethrow;
    }
  }

  // Busca uma meta específica pelo ID.
  Future<Goal?> getById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableGoals,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Goal.fromMap(maps.first);
    }
    return null;
  }

  // Busca todas as metas.
  Future<List<Goal>> getAll() async {
    final db = await dbHelper.database;
    final maps = await db.query(DatabaseHelper.tableGoals);
    return List.generate(maps.length, (i) {
      return Goal.fromMap(maps[i]);
    });
  }

  /// Calcula o progresso de uma meta específica.
  /// Retorna um Map com o valor total alcançado e o progresso percentual.
  /// Exemplo de uso: `getGoalProgress('uuid-da-meta')`
  Future<Map<String, double>> getGoalProgress(String goalId) async {
    final db = await dbHelper.database;
    
    // Query SQL com JOIN e agregação.
    // 1. `SELECT SUM(T.value)`: Soma os valores de todas as transações encontradas.
    //    - `COALESCE(..., 0)`: Se a soma for nula (nenhuma transação), retorna 0.
    // 2. `FROM goals G`: Começa pela tabela de metas, com alias G.
    // 3. `LEFT JOIN transactions T ON T.goalId = G.id`: Junta com a tabela de transações (T) onde
    //    o `goalId` da transação corresponde ao `id` da meta. LEFT JOIN é usado para incluir a meta
    //    mesmo que ela não tenha nenhuma transação ainda.
    // 4. `WHERE G.id = ?`: Filtra para a meta específica que queremos.
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(T.value), 0) as currentAmount
      FROM ${DatabaseHelper.tableGoals} G
      LEFT JOIN ${DatabaseHelper.tableTransactions} T ON T.goalId = G.id
      WHERE G.id = ?
    ''', [goalId]);

    if (result.isNotEmpty) {
      final currentAmount = (result.first['currentAmount'] as num).toDouble();
      return {'currentAmount': currentAmount};
    }

    return {'currentAmount': 0.0};
  }
}
