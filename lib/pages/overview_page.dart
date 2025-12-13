import 'package:financas_app/data/datasources/local/goal_datasource.dart';
import 'package:financas_app/data/datasources/local/transaction_datasource.dart';
import 'package:financas_app/models/goal.dart';
import 'package:financas_app/models/transaction.dart';
import 'package:financas_app/widgets/forms/goal_form.dart';
import 'package:financas_app/widgets/section_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> with WidgetsBindingObserver {
  // Variáveis de estado para a seção de Resumo
  double _gains = 0.0;
  double _spends = 0.0;
  int _transactionCount = 0;
  double _finalBalance = 0.0;
  double _avgGains = 0.0;
  double _avgSpends = 0.0;
  int _numberOfDays = 1;
  List<Map<String, dynamic>> _groups = [];

  // Future para a lista de Metas
  late Future<List<Goal>> _goalsFuture;

  // Future para a lista de gastos
  late Future<List<Transaction>> _transactionsFuture;

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

  void _loadTransactions(){
    setState(() {
      _transactionsFuture = _transactionDataSource.getAll();
    });
  }

  // Carrega e calcula os dados do resumo (ganhos, gastos, etc.)
  void _loadSummary() async {
    if (_selectedRange == null) return;

    final start = _selectedRange!.start;
    final end = _selectedRange!.end;


    final groups = await _transactionDataSource.getExpensesSumByGroup(start, end);



    // Atualiza o estado com os novos valores
    setState(() {
      _groups = groups;

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

  // Abre o formulário de meta e recarrega os dados quando ele é fechado
  void _showGoalForm({Goal? goal}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => GoalForm(goal: goal),
    );
    _refreshData(); // Garante que a UI reflita quaisquer alterações
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final selectedText = _selectedRange == null
        ? 'Selecione o período'
        : '${dateFormat.format(_selectedRange!.start)} → ${dateFormat.format(_selectedRange!.end)}';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          SectionContainer(
            title: 'Metas',
            child: _buildGoalsList(),
          ),
          const SizedBox(height: 16),
          SectionContainer(
            title: 'Resumo',
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.blueAccent),
                        ],
                      ),
                    ),
                  ),
                ),
                GridView.count(
                  padding: const EdgeInsets.all(8),
                  crossAxisCount: 2,
                  childAspectRatio: 1.8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ..._groups.map((group) {
                      final value = NumberFormat.simpleCurrency(locale: 'pt_BR').format(group['total']);
                      return _buildDashboardCard(group['name'], value);
                    })
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    return FutureBuilder<List<Goal>>(
      future: _goalsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 150,
            child: Center(child: Text('Erro ao carregar metas: ${snapshot.error}')),
          );
        }

        final goals = snapshot.data ?? [];

        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: goals.length + 1, // +1 para o card de "Adicionar Meta"
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              if (index == goals.length) {
                // Card para adicionar nova meta
                return SizedBox(
                  width: 200,
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showGoalForm(),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 40),
                          SizedBox(height: 8),
                          Text('Adicionar Meta'),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final goal = goals[index];
              // Card de cada meta individual
              return SizedBox(
                width: 200,
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: InkWell(
                    onTap: () => _showGoalForm(goal: goal),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          // FutureBuilder aninhado para buscar o progresso de cada meta individualmente
                          FutureBuilder<Map<String, double>>(
                            future: _goalDataSource.getGoalProgress(goal.id),
                            builder: (context, progressSnapshot) {
                              if (progressSnapshot.connectionState == ConnectionState.waiting) {
                                return const LinearProgressIndicator();
                              }
                              if (progressSnapshot.hasError || !progressSnapshot.hasData) {
                                return const Text('Erro', style: TextStyle(color: Colors.red));
                              }

                              final currentAmount = progressSnapshot.data!['currentAmount'] ?? 0.0;
                              final progress = goal.targetValue > 0 ? currentAmount / goal.targetValue : 0.0;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'R\$ ${currentAmount.toStringAsFixed(2)} / R\$ ${goal.targetValue.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDashboardCard(String title, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
