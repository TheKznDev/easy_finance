import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

/// Exporta todas as transações em um arquivo CSV e retorna o caminho do arquivo salvo.
/// Lança exceção caso ocorra algum erro.
Future<String> exportAllTransactionsToCsv() async {
  final box = Hive.box<Transaction>('transactions');
  final transactions = box.values.toList();

  // Monta o cabeçalho do CSV
  final csvBuffer = StringBuffer();
  csvBuffer.writeln('ID,Descrição,Valor,Data');

  final dateFormat = DateFormat('yyyy-MM-dd');

  for (final t in transactions) {
    final id = t.key;
    final desc = t.descricao.replaceAll('"', '""');
    // Valor em notação padrão (.) e sempre com 2 casas
    final valor = t.valor.toStringAsFixed(2);
    final data = dateFormat.format(t.dt_transacao);
    csvBuffer.writeln('$id,"$desc",$valor,$data');
  }

  // Salva em um diretório temporário/documentos
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/transacoes_export_${DateTime.now().millisecondsSinceEpoch}.csv';
  final outFile = File(filePath);
  await outFile.writeAsString(csvBuffer.toString());

  return filePath;
}
