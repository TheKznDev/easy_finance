import 'package:financas_app/helpers/hive_helper.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _selectedPeriod = 'Este Mês';
  Map<String, dynamic> _summaryData = {};
  int _numberOfDays = 1;
  final hiveHelper = HiveHelper();

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  void _loadSummary() async {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;
    int days;

    switch (_selectedPeriod) {
      case 'Esta Semana':
        start = now.subtract(Duration(days: now.weekday - 1));
        days = now.weekday;
        break;
      case 'Este Mês':
        start = DateTime(now.year, now.month, 1);
        days = now.day;
        break;
      case 'Este Ano':
        start = DateTime(now.year, 1, 1);
        days = now.difference(start).inDays + 1;
        break;
      default: // Desde o início
        start = DateTime(2000);
        days = now.difference(start).inDays + 1;
        break;
    }

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

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              isExpanded: true,
              underline: Container(
                height: 2,
                color: Colors.lightBlueAccent,
              ),
              items: <String>['Esta Semana', 'Este Mês', 'Este Ano', 'Desde o início']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPeriod = newValue;
                    _loadSummary();
                  });
                }
              },
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(8),
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDashboardCard(
                    'Transações', '$transactionCount', Colors.lightBlueAccent),
                _buildDashboardCard(
                    'Saldo Final', 'R\$ ${finalBalance.toStringAsFixed(2)}', Colors.lightGreen),
                _buildDashboardCard(
                    'Ganhos', 'R\$ ${gains.toStringAsFixed(2)}', Colors.green),
                _buildDashboardCard(
                    'Gastos', 'R\$ ${spends.toStringAsFixed(2)}', Colors.red),
                _buildDashboardCard(
                    'Média de Gastos', 'R\$ ${avgSpends.toStringAsFixed(2)}', Colors.red),
                _buildDashboardCard(
                    'Média de Ganhos', 'R\$ ${avgGains.toStringAsFixed(2)}', Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      color: color.withAlpha(38),
      margin: const EdgeInsets.all(8),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}
