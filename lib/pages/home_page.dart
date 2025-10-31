import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../widgets/dashboard.dart';
import '../widgets/month_carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List<dynamic>>? transactions;
  int _selectedIndex = 0;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    final allRows = await dbHelper.getTransactions();
    setState(() {
      transactions = allRows.map((row) => row.values.toList()).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _pickAndParseCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      try {
        final file = File(result.files.single.path!);
        final input = file.openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter())
            .toList();

        for (var i = 1; i < fields.length; i++) {
          await dbHelper.insertTransaction({
            'descricao': fields[i][0],
            'descricao2': fields[i][1],
            'valor': fields[i][2],
            'dt_transacao': fields[i][3],
          });
        }
        _loadTransactions();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao ler o arquivo: $e'),
          ),
        );
      }
    } else {
      // User canceled the picker
    }
  }

  void _addTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool isGain = false;
            DateTime selectedDate = DateTime.now();
            final dateController = TextEditingController(
                text: DateFormat('dd/MM/yyyy').format(selectedDate));
            final descriptionController = TextEditingController();
            final valueController = TextEditingController();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Adicionar Transação',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valueController,
                    decoration: const InputDecoration(labelText: 'Valor'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Gasto'),
                      Switch(
                        value: isGain,
                        onChanged: (value) {
                          setState(() {
                            isGain = value;
                          });
                        },
                      ),
                      const Text('Ganho'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Data',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                          dateController.text =
                              DateFormat('dd/MM/yyyy').format(selectedDate);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final value = double.parse(valueController.text);
                      await dbHelper.insertTransaction({
                        'descricao': descriptionController.text,
                        'valor': isGain ? value : -value,
                        'dt_transacao': selectedDate.toIso8601String(),
                      });
                      _loadTransactions();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Adicionar'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      Dashboard(),
      const MonthCarousel(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Dashboard' : 'Mês a Mês'),
        centerTitle: true,
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedIndex == 0 ? _pickAndParseCsv : _addTransaction,
        child: Icon(_selectedIndex == 0 ? Icons.upload_file : Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.dashboard),
              color: _selectedIndex == 0
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              onPressed: () => _onItemTapped(0),
            ),
            const SizedBox(width: 40), // Spacer for the FAB
            IconButton(
              icon: const Icon(Icons.calendar_today),
              color: _selectedIndex == 1
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              onPressed: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
    );
  }
}
