import 'package:hive/hive.dart';
import '../models/transaction.dart';

class HiveHelper {
  static const String _boxName = 'transactions';

  Future<void> addTransaction(Transaction transaction) async {
    final box = await Hive.openBox<Transaction>(_boxName);
    await box.add(transaction);
  }

  Future<void> addTransactions(List<Transaction> transactions) async {
    final box = await Hive.openBox<Transaction>(_boxName);
    for (var transaction in transactions) {
      // Evita duplicados, considerando uma combinação de data, descrição e valor.
      // Você pode ajustar a lógica de verificação conforme sua necessidade.
      final exists = box.values.any((t) =>
          t.dt_transacao == transaction.dt_transacao &&
          t.descricao == transaction.descricao &&
          t.valor == transaction.valor);

      if (!exists) {
        await box.add(transaction);
      }
    }
  }

  Future<Map<String, dynamic>> getSummary(DateTime start, DateTime end) async {
    final box = await Hive.openBox<Transaction>(_boxName);
    final transactions = box.values
        .where((t) => t.dt_transacao.isAfter(start) && t.dt_transacao.isBefore(end))
        .toList();

    double gains = 0;
    double spends = 0;

    for (var t in transactions) {
      if (t.valor > 0) {
        gains += t.valor;
      } else {
        spends += t.valor;
      }
    }

    return {
      'gains': gains,
      'spends': spends,
      'transactionCount': transactions.length,
    };
  }
}
