import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/home_page.dart';

void main() {
  initializeDateFormatting('pt_BR', null).then((_) {

    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrossel de Meses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF124191)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
