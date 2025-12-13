import 'package:sqflite/sqflite.dart';
import '../../../models/category.dart';
import '../../local/database_helper.dart';

class CategoryDataSource {
  final dbHelper = DatabaseHelper.instance;

  // Insere uma nova categoria.
  Future<int> insert(Category category) async {
    try {
      final db = await dbHelper.database;
      return await db.insert(DatabaseHelper.tableCategories, category.toMap());
    } catch (e) {
      print('Erro ao inserir categoria: $e');
      rethrow;
    }
  }

  // Atualiza uma categoria existente.
  Future<int> update(Category category) async {
    try {
      final db = await dbHelper.database;
      return await db.update(
        DatabaseHelper.tableCategories,
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      print('Erro ao atualizar categoria: $e');
      rethrow;
    }
  }

  // Deleta uma categoria. As transações associadas terão seu `categoryId` definido como NULL.
  Future<int> delete(String id) async {
    try {
      final db = await dbHelper.database;
      return await db.delete(
        DatabaseHelper.tableCategories,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao deletar categoria: $e');
      rethrow;
    }
  }

  // Busca uma categoria específica pelo ID.
  Future<Category?> getById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  // Busca todas as categorias.
  Future<List<Category>> getAll() async {
    final db = await dbHelper.database;
    final maps = await db.query(DatabaseHelper.tableCategories, orderBy: 'name ASC');
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  /// Calcula o total gasto por categoria em um determinado período.
  /// Retorna uma lista de mapas, onde cada mapa contém a categoria e o total gasto.
  /// Exemplo de uso: `getSpendsPerCategory(startDate, endDate)`
  Future<List<Map<String, dynamic>>> getSpendsPerCategory(DateTime start, DateTime end) async {
    final db = await dbHelper.database;
    final startTime = start.millisecondsSinceEpoch;
    final endTime = end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)).millisecondsSinceEpoch;

    // Query SQL com JOIN, GROUP BY e agregação.
    // 1. `SELECT C.*, SUM(T.value) as total`: Seleciona todos os campos da categoria e a soma dos valores das transações.
    // 2. `FROM categories C`: Começa pela tabela de categorias.
    // 3. `JOIN transactions T ON C.id = T.categoryId`: Junta com as transações que pertencem a cada categoria.
    // 4. `WHERE T.type = 'EXPENSE' AND T.date BETWEEN ? AND ?`: Filtra apenas por despesas dentro do período.
    // 5. `GROUP BY C.id`: Agrupa os resultados por ID de categoria para que o SUM funcione corretamente.
    // 6. `ORDER BY total DESC`: Ordena para mostrar as categorias com maiores gastos primeiro.
    final result = await db.rawQuery('''
      SELECT 
        C.*, 
        COALESCE(SUM(T.value), 0) as total
      FROM ${DatabaseHelper.tableCategories} C
      JOIN ${DatabaseHelper.tableTransactions} T ON C.id = T.categoryId
      WHERE T.type = 'EXPENSE' AND T.date BETWEEN ? AND ?
      GROUP BY C.id
      ORDER BY total DESC
    ''', [startTime, endTime]);

    return result.map((map) {
      return {
        'category': Category.fromMap(map),
        'total': (map['total'] as num).toDouble(),
      };
    }).toList();
  }
}
