import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

Future<void> pickAndParseCsv(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv']
  );

  if (result != null && result.files.single.path != null) {
    try {
      final file = File(result.files.single.path!);
      final box = Hive.box<Transaction>('transactions');
      int lineCount = 0;
      List<String> cabecalho = [];
      String delimitador = ',';

      final stream = file
          .openRead()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        String linha = line.trim().toLowerCase();
        if (linha //Verificar cabeçalho da tabela para começar a importação
            .contains(RegExp(
          r'^(?=.*\b(data|data lançamento|date)\b)'
          r'(?=.*\b(descrição|descricao|histórico|historico|lançamento|lancamento)\b)'
          r'(?=.*\bvalor\b).*$',
          caseSensitive: false,
        ))){

          linha.contains(';')? delimitador = ';' : delimitador = ',';
          lineCount++;

          cabecalho = linha.split(delimitador);

          //Normalizar conforme regex acima

          final Map<RegExp, String> normalizationMap = {
            RegExp(r'data|date'): 'data',
            RegExp(r'descri[cç][aã]o|historico|hist[oó]rico|lancamento|lançamento'): 'descricao',
            RegExp(r'valor'): 'valor',
          };

          for (int i = 0; i < cabecalho.length; i++) {
            for (final entry in normalizationMap.entries) {
              if (entry.key.hasMatch(cabecalho[i])) {
                cabecalho[i] = entry.value;
                break; // pára no primeiro match
              }
            }
          }

        }else if (lineCount > 0) {
          //Copiando os dados para o banco de dados
          final values = line.split(delimitador);
          final date = values[cabecalho.indexOf('data')];

          final parsedDate = DateFormat('dd/MM/yyyy').parse(date);
          final formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

          final value = (values[cabecalho.indexOf('valor')]).replaceAll('.', '').replaceAll(',', '.');

          final description = values[cabecalho.indexOf('descricao')];

          final transaction = Transaction();
          transaction.dt_transacao = parsedDate;
          transaction.valor = double.parse(value);
          transaction.descricao = description;

          await box.add(transaction);

          transaction.save();
        }



      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV importado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao importar CSV: ${e.toString()}')),
      );
    }
  }
}
