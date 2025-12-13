import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/datasources/local/transaction_datasource.dart';
import '../models/transaction.dart';

// Função para ler o arquivo CSV linha por linha
Future<List<String>> lerArquivo(String filePath) async {
  final file = File(filePath);
  final lines = <String>[];

  final stream = file
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  await for (final line in stream) {
    lines.add(line);
  }
  return lines;
}

Future<void> pickAndParseCsv(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (result != null && result.files.single.path != null) {
    try {
      final filePath = result.files.single.path!;
      final lines = await lerArquivo(filePath);
      final transactionDataSource = TransactionDataSource();
      int lineCount = 0;
      List<String> cabecalho = [];
      String delimitador = ',';

      for (final line in lines) {
        String linha = line.trim().toLowerCase();
        if (linha.contains(RegExp(
          r'^(?=.*\b(data|data lançamento|date)\b)'
          r'(?=.*\b(descrição|descricao|histórico|historico|lançamento|lancamento)\b)'
          r'(?=.*\bvalor\b).*$',
          caseSensitive: false,
        ))) {
          linha.contains(';') ? delimitador = ';' : delimitador = ',';
          lineCount++;

          cabecalho = linha.split(delimitador);

          final Map<RegExp, String> normalizationMap = {
            RegExp(r'data|date'): 'data',
            RegExp(r'descri[cç][aã]o|historico|hist[oó]rico|lancamento|lançamento'): 'descricao',
            RegExp(r'valor'): 'valor',
          };

          for (int i = 0; i < cabecalho.length; i++) {
            for (final entry in normalizationMap.entries) {
              if (entry.key.hasMatch(cabecalho[i])) {
                cabecalho[i] = entry.value;
                break;
              }
            }
          }
        } else if (lineCount > 0) {
          final values = line.split(delimitador);
          final date = values[cabecalho.indexOf('data')];

          final parsedDate = DateFormat('dd/MM/yyyy').parse(date);

          String valorBruto = values[cabecalho.indexOf('valor')].trim();
          String value;
          final ponto = valorBruto.contains('.');
          final virgula = valorBruto.contains(',');

          if (ponto && virgula) {
            value = valorBruto.replaceAll('.', '').replaceAll(',', '.');
          } else if (!ponto && virgula) {
            value = valorBruto.replaceAll(',', '.');
          } else if (ponto && !virgula) {
            value = valorBruto;
          } else {
            value = valorBruto;
          }

          final indicesDescricao = [
            for (int i = 0; i < cabecalho.length; i++)
              if (cabecalho[i] == 'descricao') i,
          ];

          final description = indicesDescricao.map((i) => values[i]).join(' ');
          final parsedValue = double.parse(value);

          final transaction = Transaction(
            date: parsedDate,
            value: parsedValue.abs(), // Salva sempre o valor absoluto
            description: description,
            type: parsedValue < 0 ? TransactionType.expense : TransactionType.income, // Define o tipo com base no sinal
          );

          await transactionDataSource.insert(transaction);
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
