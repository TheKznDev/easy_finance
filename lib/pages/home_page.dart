import 'package:financas_app/pages/help.dart';
import 'package:financas_app/pages/settings_menu_page.dart';
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


  late List<Widget> _pages;
  DateTime _currentMonth = DateTime.now();
  @override
  void initState() {
    super.initState();

    _pages = [
      const Dashboard(),
      MonthCarousel(
        onMonthChanged: (month) {
          _currentMonth = month; // atualiza o mês sempre que o carrossel muda
        },
      ),
      const SettingsPage(),
    ];
  }


  

  final List<String> _titles = const [
    '📊 Dashboard',
    '📅 Mês a Mês',
    '+ Mais Opções',
  ];

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
        return AddTransactionForm(
          // passa o mês atual apenas se estiver na aba "Mês a Mês"
          defaultMonth: _selectedIndex == 1 ? _currentMonth : null,
        );
      },
    );
  }


  Future<void> _pickAndParseCsvWithLoading() async {
    setState(() => _isLoading = true);
    try {
      await pickAndParseCsv(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Transaction>>(
      valueListenable: Hive.box<Transaction>('transactions').listenable(),
      builder: (context, box, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _titles[_selectedIndex],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 2,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                tooltip: 'Ajuda',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpPage()),
                  );
                },
              ),

            ],
          ),

          body: Stack(
            children: [
              _pages[_selectedIndex],
              if (_isLoading)
                const Center(
                  child: AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text("Importando CSV..."),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          floatingActionButton: _buildFloatingButton(context),

          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,

          bottomNavigationBar: _buildBottomNavigationBar(context),
        );
      },
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    // Desabilita o FAB na tela de Configurações
    if (_selectedIndex == 2) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton.extended(
        key: ValueKey<int>(_selectedIndex),
        onPressed: () {
          switch (_selectedIndex) {
            case 0:
              _pickAndParseCsvWithLoading();
              break;

            default:
              _showAddTransactionModal();
              break;
          }

        },
        label: Text(
          _selectedIndex == 0 ? 'Importar CSV' : 'Adicionar',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: Icon(
          _selectedIndex == 0 ? Icons.upload_file : Icons.add,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            color: _selectedIndex == 0
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            onPressed: () => _onItemTapped(0),
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            color: _selectedIndex == 1
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            onPressed: () => _onItemTapped(1),
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            color: _selectedIndex == 2
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            onPressed: () => _onItemTapped(2),
          ),
        ],
      ),
    );
  }
}
