import 'package:financas_app/data/datasources/local/transaction_datasource.dart';
import 'package:financas_app/models/transaction.dart';
import 'package:financas_app/widgets/forms/transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthCarousel extends StatefulWidget {
  final ValueChanged<DateTime>? onMonthChanged;
  const MonthCarousel({super.key, this.onMonthChanged});

  @override
  State<MonthCarousel> createState() => _MonthCarouselState();
}

class _MonthCarouselState extends State<MonthCarousel> {
  late PageController _controller;
  final int _initialPage = 10000;
  late DateTime _baseMonth;
  final Set<String> _selectedIds = {}; // Armazena IDs (String) do SQLite
  bool _selectionMode = false;

  // Instância do DataSource de Transações
  final _transactionDataSource = TransactionDataSource();

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _initialPage);
    _baseMonth = DateTime.now();
  }

  DateTime _monthForIndex(int index) {
    int diff = index - _initialPage;
    return DateTime(_baseMonth.year, _baseMonth.month + diff);
  }

  void _showTransactionModal(Transaction? transaction, DateTime currentMonth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TransactionForm(
          transaction: transaction,
          defaultMonth: currentMonth,
        );
      },
    ).then((_) =>
        setState(() {})); // Recarrega o estado para refletir as alterações
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      _selectionMode = _selectedIds.isNotEmpty;
    });
  }

  Future<void> _deleteSelected(BuildContext context) async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Transações'),
        content: Text(
            'Tem certeza que deseja excluir ${_selectedIds.length} transação(ões)?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      for (final id in _selectedIds) {
        await _transactionDataSource.delete(id);
      }

      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir transações: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Transaction>> _getTransactionsForMonth(DateTime monthDate) async {
    final startOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final endOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);

    final transactions = await _transactionDataSource.findByPeriod(startOfMonth, endOfMonth);
    
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      onPageChanged: (index) {
        final currentMonth = _monthForIndex(index);
        widget.onMonthChanged?.call(currentMonth);
        setState(() {});
      },
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final monthDate = _monthForIndex(index);
        final monthName = DateFormat('MMMM yyyy', 'pt_BR').format(monthDate);

        return Scaffold(
          floatingActionButton: _selectionMode
              ? _buildDeleteFab(context)
              : FloatingActionButton( // FAB agora chama diretamente o modal de transação
                  onPressed: () => _showTransactionModal(null, monthDate),
                  child: const Icon(Icons.add),
                ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: FutureBuilder<List<Transaction>>(
            future: _getTransactionsForMonth(monthDate),
            builder: (context, snapshot) {
              final transactions = snapshot.data ?? [];
              final double total = transactions.fold(
                  0.0,
                  (sum, item) =>
                      sum +
                      (item.type == TransactionType.income
                          ? item.value
                          : -item.value));

              return _selectionMode
                  ? _buildSelectionAppBar()
                  : _buildTotalFooter(total);
            },
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  monthName[0].toUpperCase() + monthName.substring(1),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Transaction>>(
                  future: _getTransactionsForMonth(monthDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }

                    final transactions = snapshot.data ?? [];

                    if (transactions.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhuma transação neste mês.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return _buildTransactionTile(transaction);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    final isSelected = _selectedIds.contains(transaction.id);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (_selectionMode) {
          _toggleSelection(transaction.id);
        } else {
          _showTransactionModal(transaction, transaction.date);
        }
      },
      onLongPress: () {
        _toggleSelection(transaction.id);
      },
      child: Card(
        elevation: 2,
        color: isSelected ? Colors.lightBlue.shade100 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: Colors.blue.shade700, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.withAlpha(38),
                child: Icon(
                  transaction.type == TransactionType.income
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: transaction.type == TransactionType.income
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(transaction.date),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                'R\$ ${transaction.value.toStringAsFixed(2)}',
                style: TextStyle(
                  color: transaction.type == TransactionType.income
                      ? Colors.blue
                      : Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalFooter(double total) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Saldo do Mês', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'R\$ ${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: total >= 0 ? Colors.blue : Colors.red,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionAppBar() {
    return BottomAppBar(
      color: Colors.blue.shade700,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _selectedIds.clear();
                  _selectionMode = false;
                });
              },
            ),
            const SizedBox(width: 8),
            Text(
              '${_selectedIds.length} selecionado(s)',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _deleteSelected(context),
      backgroundColor: Colors.red,
      child: const Icon(Icons.delete),
    );
  }
}
