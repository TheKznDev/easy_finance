import 'package:financas_app/widgets/add_transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/transaction.dart';
import '../utils/csv_parser.dart';
import '../widgets/dashboard.dart';
import '../widgets/month_carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoading = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const AddTransactionForm();
      },
    );
  }

  Future<void> _pickAndParseCsvWithLoading() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await pickAndParseCsv(context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Transaction>>(
      valueListenable: Hive.box<Transaction>('transactions').listenable(),
      builder: (context, box, _) {
        final List<Widget> widgetOptions = <Widget>[
          const Dashboard(),
          const MonthCarousel(), // Manter MonthCarousel como está por enquanto
        ];

        return Scaffold(
          appBar: AppBar(title: Text(_selectedIndex == 0 ? 'Dashboard' : 'Mês a Mês'), centerTitle: true),
          body: Stack(
            children: [
              widgetOptions.elementAt(_selectedIndex),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_selectedIndex == 0) {
                _pickAndParseCsvWithLoading();
              } else {
                _showAddTransactionModal();
              }
            },
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
                  color: _selectedIndex == 0 ? Theme.of(context).colorScheme.primary : Colors.grey,
                  onPressed: () => _onItemTapped(0),
                ),
                const SizedBox(width: 40),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  color: _selectedIndex == 1 ? Theme.of(context).colorScheme.primary : Colors.grey,
                  onPressed: () => _onItemTapped(1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
