import 'package:financas_app/data/datasources/local/goal_datasource.dart';
import 'package:financas_app/data/datasources/local/transaction_datasource.dart';
import 'package:financas_app/models/goal.dart';
import 'package:financas_app/widgets/forms/goal_form.dart';
import 'package:financas_app/widgets/section_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/summary_grid.dart';
import '../widgets/summary_section.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage>
    with WidgetsBindingObserver {
  // Future para a lista de Metas
  late Future<List<Goal>> _goalsFuture;

  // Future para o resumo de gastos
  late Future<List<Map<String, dynamic>>> _summaryFuture;

  // Instâncias dos DataSources e Repositories
  final _transactionDataSource = TransactionDataSource();

  final _goalDataSource = GoalDataSource();

  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Define o período inicial como o mês corrente
    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
    _refreshData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  // Recarrega todos os dados da página
  void _refreshData() {
    _loadSummary();
    _loadGoals();
  }

  // Carrega os dados da lista de metas
  void _loadGoals() {
    setState(() {
      _goalsFuture = _goalDataSource.getAll();
    });
  }

  // Carrega e calcula os dados do resumo (ganhos, gastos, etc.)
  void _loadSummary() {
    if (_selectedRange == null) {
      setState(() {
        _summaryFuture = Future.value([]);
      });
      return;
    }

    final start = _selectedRange!.start;
    final end = _selectedRange!.end;

    setState(() {
      _summaryFuture = _transactionDataSource.getExpensesSumByGroup(start, end);
    });
  }

  Future<void> _pickDateRange() async {
    final DateTime now = DateTime.now();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedRange,
      firstDate: DateTime(2000),
      lastDate: now,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedRange = picked;
        _loadSummary(); // Recarrega o resumo com o novo período
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final selectedText = _selectedRange == null
        ? 'Selecione o período'
        : '${dateFormat.format(_selectedRange!.start)} → ${dateFormat.format(_selectedRange!.end)}';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          const SizedBox(height: 16),
          SectionContainer(
            title: 'Resumo de Gastos',
            child: SummarySection(
              title: 'Resumo de Gastos',
              selectedText: selectedText,
              onPickDateRange: _pickDateRange,
              summaryGrid: SummaryGrid(
                summaryFuture: _summaryFuture,
                accentColor: Colors.greenAccent,
                onRefresh: _refreshData,
              ),
              accentColor: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }
}
