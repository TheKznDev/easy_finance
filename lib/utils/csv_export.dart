import 'dart:io';
import 'package:intl/intl.dart';

import '../data/datasources/local/transaction_datasource.dart';
import '../models/transaction.dart';

/// Exporta todas as transações para um arquivo CSV usando o TransactionDataSource.
/// Retorna o caminho do arquivo salvo.
Future<String> exportAllTransactionsToCsv(String selectedPath) async {
  // Instancia o DataSource para acessar os dados do SQLite.
  final transactionDataSource = TransactionDataSource();
  final transactions = await transactionDataSource.getAll();

  if (transactions.isEmpty) {
    throw Exception('Nenhuma transação encontrada para exportar.');
  }

  final csvBuffer = StringBuffer();
  // Cabeçalho do CSV - mantendo o formato original para compatibilidade na importação
  csvBuffer.writeln('ID,Descrição,Valor,Data');
  final dateFormat = DateFormat('yyyy-MM-dd');

  for (final t in transactions) {
    final id = t.id;
    // Escapa aspas duplas na descrição para não quebrar o formato CSV
    final desc = t.description.replaceAll('"', '""');
    // Define o valor com sinal: negativo para despesas, positivo para receitas.
    final valor = t.type == TransactionType.expense ? -t.value : t.value;
    final data = dateFormat.format(t.date);

    // Formata a linha do CSV, colocando a descrição entre aspas para tratar vírgulas no texto
    csvBuffer.writeln('$id,"$desc",${valor.toStringAsFixed(2)},$data');
  }

  final outFile = File(selectedPath);
  await outFile.writeAsString(csvBuffer.toString());
  return outFile.path;
}
