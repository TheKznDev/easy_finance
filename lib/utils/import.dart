import 'package:flutter/material.dart';
import 'csv_parser.dart';

class ImportUtils {
  
  /// Exibe um diálogo para importar CSV e processa o arquivo.
  static Future<void> importarTransacoesCsv(BuildContext context) async {
    await pickAndParseCsv(context);
  }
}
