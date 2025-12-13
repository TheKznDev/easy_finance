import 'package:sqflite/sqflite.dart' hide Transaction;
import '../../../models/transaction.dart';
import '../../local/database_helper.dart';

class TransactionDataSource {
  final dbHelper = DatabaseHelper.instance;

  // Insere uma nova transação no banco de dados.
  Future<int> insert(Transaction transaction) async {
    try {
      final db = await dbHelper.database;
      return await db.insert(DatabaseHelper.tableTransactions, transaction.toMap());
    } catch (e) {
      print('Erro ao inserir transação: $e');
      rethrow; // Propaga o erro para a camada superior (Repository)
    }
  }

  // Atualiza uma transação existente.
  Future<int> update(Transaction transaction) async {
    try {
      final db = await dbHelper.database;
      return await db.update(
        DatabaseHelper.tableTransactions,
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      print('Erro ao atualizar transação: $e');
      rethrow;
    }
  }

  // Deleta uma transação pelo seu ID.
  Future<int> delete(String id) async {
    try {
      final db = await dbHelper.database;
      return await db.delete(
        DatabaseHelper.tableTransactions,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao deletar transação: $e');
      rethrow;
    }
  }

  // Busca uma transação específica pelo ID.
  Future<Transaction?> getById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
  }

  // Busca todas as transações.
  Future<List<Transaction>> getAll() async {
    final db = await dbHelper.database;
    final maps = await db.query(DatabaseHelper.tableTransactions);
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  /// Busca transações dentro de um período específico.
  /// Útil para gerar resumos e extratos mensais/semanais.
  Future<List<Transaction>> findByPeriod(DateTime start, DateTime end) async {
    final db = await dbHelper.database;
    // Converte as datas para o formato que está no banco (millisecondsSinceEpoch)
    final startTime = start.millisecondsSinceEpoch;
    // Adiciona um dia menos um milissegundo para garantir que o dia final seja incluído por completo.
    final endTime = end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)).millisecondsSinceEpoch;

    final maps = await db.query(
      DatabaseHelper.tableTransactions,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startTime, endTime],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  /// Busca todas as transações associadas a um grupo específico.
  Future<List<Transaction>> findByGroupId(String groupId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableTransactions,
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  /// Calcula o total de despesas para um grupo específico em um período.
  Future<double> getGroupExpensesByPeriod(String groupId, DateTime start, DateTime end) async {
    final db = await dbHelper.database;
    final startTime = start.millisecondsSinceEpoch;
    final endTime = end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)).millisecondsSinceEpoch;

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(value), 0.0) as total
      FROM ${DatabaseHelper.tableTransactions}
      WHERE groupId = ? AND type = 'EXPENSE' AND date BETWEEN ? AND ?
    ''', [groupId, startTime, endTime]);

    if (result.isNotEmpty) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  /// Calcula e agrupa os totais de despesas por grupo em um determinado período.
  /// Retorna uma lista de mapas, onde cada mapa contém o nome do grupo e o total gasto.
  Future<List<Map<String, dynamic>>> getExpensesSumByGroup(DateTime start, DateTime end) async {
    final db = await dbHelper.database;
    final startTime = start.millisecondsSinceEpoch;
    final endTime = end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)).millisecondsSinceEpoch;

    // 1. SELECT G.name, SUM(T.value) as total: Seleciona o nome do grupo e a soma dos valores.
    // 2. FROM transactions T JOIN groups G ON T.groupId = G.id: Junta transações com grupos.
    // 3. WHERE T.groupId IS NOT NULL...: Filtra por despesas, no período, que possuem um grupo.
    // 4. GROUP BY T.groupId: Agrupa os resultados para que o SUM() funcione por grupo.
    // 5. ORDER BY total DESC: Ordena para mostrar os maiores gastos primeiro.
    final result = await db.rawQuery('''
      SELECT
        COALESCE(G.name, 'Demais gastos') as name,
        COALESCE(SUM(T.value), 0.0) as total
      FROM ${DatabaseHelper.tableTransactions} T
      LEFT JOIN ${DatabaseHelper.tableGroups} G ON T.groupId = G.id
      WHERE
        T.type = 'EXPENSE' AND
        T.date BETWEEN ? AND ?
      GROUP BY
        CASE WHEN T.groupId IS NULL THEN 'ungrouped' ELSE T.groupId END
      ORDER BY
        total DESC
    ''', [startTime, endTime]);

    return result;
  }

  /// Calcula o total de despesas não agrupadas em um período.
  Future<double> getUngroupedExpensesByPeriod(DateTime start, DateTime end) async {
    final db = await dbHelper.database;
    final startTime = start.millisecondsSinceEpoch;
    final endTime = end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)).millisecondsSinceEpoch;

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(value), 0.0) as total
      FROM ${DatabaseHelper.tableTransactions}
      WHERE groupId IS NULL AND type = 'EXPENSE' AND date BETWEEN ? AND ?
    ''', [startTime, endTime]);

    if (result.isNotEmpty) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  /// Vincula uma transação a uma meta.
  /// Isso é feito atualizando o campo `goalId` da transação.
  Future<int> linkToGoal(String transactionId, String goalId) async {
    try {
      final db = await dbHelper.database;
      return await db.update(
        DatabaseHelper.tableTransactions,
        {'goalId': goalId},
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    } catch (e) {
      print('Erro ao vincular transação à meta: $e');
      rethrow;
    }
  }

  /// Desvincula uma transação de uma meta.
  /// Isso é feito definindo o campo `goalId` como NULL.
  Future<int> unlinkFromGoal(String transactionId) async {
    try {
      final db = await dbHelper.database;
      return await db.update(
        DatabaseHelper.tableTransactions,
        {'goalId': null},
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    } catch (e) {
      print('Erro ao desvincular transação da meta: $e');
      rethrow;
    }
  }

  Future<void> updateGroup({required String transactionId, required String groupId}) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        DatabaseHelper.tableTransactions,
        {'groupId': groupId},
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    } catch (e) {
      print('Erro ao atualizar grupo da transação: $e');
      rethrow;
    }
  }

  Future<void> updateTransactionsToGroup({
    required String groupId,
    required List<String> transactionIds,
  })async {
    try{
      final db = await dbHelper.database;
      for (final id in transactionIds) {
        await db.update(
          DatabaseHelper.tableTransactions,
          {'groupId': groupId},
          where: 'id = ?',
          whereArgs: [id],);
      }
    } catch (e) {
      print('Erro ao atualizar grupo das transações: $e');
      rethrow;

      }
    }
}
