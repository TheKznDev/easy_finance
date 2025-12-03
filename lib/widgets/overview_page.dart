import 'package:financas_app/helpers/hive_helper.dart';
import 'package:financas_app/widgets/section_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  Map<String, dynamic> _summaryData = {};
  int _numberOfDays = 1;
  final hiveHelper = HiveHelper();

  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    // Inicialmente: mostra o mês atual
    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
    _loadSummary();
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
        _loadSummary();
      });
    }
  }

  void _loadSummary() async {
    if (_selectedRange == null) return;

    final start = _selectedRange!.start;
    final end = _selectedRange!.end;
    final days = end.difference(start).inDays + 1;

    final data = await hiveHelper.getSummary(start, end);
    setState(() {
      _summaryData = data;
      _numberOfDays = days > 0 ? days : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double gains = _summaryData['gains'] ?? 0.0;
    final double spends = _summaryData['spends'] ?? 0.0;
    final int transactionCount = _summaryData['transactionCount'] ?? 0;
    final double finalBalance = gains + spends;
    final double avgGains = gains / _numberOfDays;
    final double avgSpends = spends / _numberOfDays;

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
                    _buildDashboardCard('Transações', '$transactionCount'),
                    _buildDashboardCard('Saldo Final', 'R\$ ${finalBalance.toStringAsFixed(2)}'),
                    _buildDashboardCard('Ganhos', 'R\$ ${gains.toStringAsFixed(2)}'),
                    _buildDashboardCard('Gastos', 'R\$ ${spends.toStringAsFixed(2)}'),
                    _buildDashboardCard('Média diária de Gastos', 'R\$ ${avgSpends.toStringAsFixed(2)}'),
                    _buildDashboardCard('Média diária de Ganhos', 'R\$ ${avgGains.toStringAsFixed(2)}'),
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
    // Dummy data for goals
    final goals = [
      {'title': 'Viagem para a praia', 'current': 1500.0, 'target': 3000.0},
      {'title': 'Novo celular', 'current': 800.0, 'target': 4000.0},
    ];

    return SizedBox(
      height: 150, // Altura fixa para a lista de metas
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: goals.length + 1,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          if (index == goals.length) {
            return SizedBox(
              width: 200,
              child: Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    print('Adicionar Meta');
                  },
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
          final progress =
              (goal['current'] as double) / (goal['target'] as double);

          return SizedBox(
            width: 200,
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['title'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${goal['current']} / R\$ ${goal['target']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
