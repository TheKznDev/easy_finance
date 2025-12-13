import 'package:sqflite/sqflite.dart';
import '../../../models/group.dart';
import '../../local/database_helper.dart';

class GroupDataSource {
  final dbHelper = DatabaseHelper.instance;

  // Insere um novo grupo.
  Future<int> insert(Group group) async {
    try {
      final db = await dbHelper.database;
      return await db.insert(DatabaseHelper.tableGroups, group.toMap());
    } catch (e) {
      print('Erro ao inserir grupo: $e');
      rethrow;
    }
  }

  // Atualiza um grupo existente.
  Future<int> update(Group group) async {
    try {
      final db = await dbHelper.database;
      return await db.update(
        DatabaseHelper.tableGroups,
        group.toMap(),
        where: 'id = ?',
        whereArgs: [group.id],
      );
    } catch (e) {
      print('Erro ao atualizar grupo: $e');
      rethrow;
    }
  }

  // Deleta um grupo. As transações associadas terão seu `groupId` definido como NULL.
  Future<int> delete(String id) async {
    try {
      final db = await dbHelper.database;
      return await db.delete(
        DatabaseHelper.tableGroups,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao deletar grupo: $e');
      rethrow;
    }
  }

  // Busca um grupo específico pelo ID.
  Future<Group?> getById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableGroups,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Group.fromMap(maps.first);
    }
    return null;
  }

  // Busca todos os grupos.
  Future<List<Group>> getAll() async {
    final db = await dbHelper.database;
    // Ordena por data de criação, do mais novo para o mais antigo.
    final maps = await db.query(DatabaseHelper.tableGroups, orderBy: 'creationDate DESC');
    return List.generate(maps.length, (i) {
      return Group.fromMap(maps[i]);
    });
  }

  // Exemplo futuro: se você quisesse calcular o total de transações de um grupo,
  // a query seria parecida com a de `getGoalProgress`.
  /*
  Future<double> getGroupTotal(String groupId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(value), 0) as total
      FROM ${DatabaseHelper.tableTransactions}
      WHERE groupId = ?
    ''', [groupId]);
    return (result.first['total'] as num).toDouble();
  }
  */
}
