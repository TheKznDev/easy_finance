import 'dart:io';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

/// Exporta todas as transações em um arquivo CSV e retorna o caminho salvo.
Future<String> exportAllTransactionsToCsv(String selectedPath) async {
  final box = Hive.box<Transaction>('transactions');
  final transactions = box.values.toList();

  if (transactions.isEmpty) {
    throw Exception('Nenhuma transação encontrada para exportar.');
  }

  final csvBuffer = StringBuffer();
  csvBuffer.writeln('ID,Descrição,Valor,Data');
  final dateFormat = DateFormat('yyyy-MM-dd');

  for (final t in transactions) {
    final id = t.key;
    final desc = t.descricao.replaceAll('"', '""');
    final valor = t.valor.toStringAsFixed(2);
    final data = dateFormat.format(t.dt_transacao);
    csvBuffer.writeln('$id,"$desc",$valor,$data');
  }

  final outFile = File(selectedPath);
  await outFile.writeAsString(csvBuffer.toString());
  return outFile.path;
}
