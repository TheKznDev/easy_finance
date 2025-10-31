import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _selectedPeriod = 'Este Mês';
  Map<String, dynamic> _summaryData = {};
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  void _loadSummary() async {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (_selectedPeriod) {
      case 'Esta Semana':
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Este Mês':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'Este Ano':
        start = DateTime(now.year, 1, 1);
        break;
      default: // Desde o início
        start = DateTime(2000);
    }

    final data = await dbHelper.getSummary(start, end);
    setState(() {
      _summaryData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double gains = _summaryData['gains'] ?? 0.0;
    final double spends = _summaryData['spends'] ?? 0.0;
    final int transactionCount = _summaryData['transactionCount'] ?? 0;
    final double finalBalance = gains + spends;

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
                color: Colors.deepOrangeAccent,
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
                    'Transações', '$transactionCount', Colors.blue),
                _buildDashboardCard(
                    'Saldo Final', 'R\$ ${finalBalance.toStringAsFixed(2)}', Colors.purple),
                _buildDashboardCard(
                    'Ganhos', 'R\$ ${gains.toStringAsFixed(2)}', Colors.green),
                _buildDashboardCard(
                    'Gastos', 'R\$ ${spends.toStringAsFixed(2)}', Colors.red),
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
      color: color.withOpacity(0.15),
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