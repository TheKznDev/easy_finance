import 'package:financas_app/models/transaction.dart';
import 'package:financas_app/widgets/add_transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  final Set<int> _selectedIds = {}; // <- IDs selecionados
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _initialPage);
    _baseMonth = DateTime.now(); //Inicializa o carousel com o mês atual
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
        return AddTransactionForm(
          transaction: transaction,
          defaultMonth: currentMonth,
        );
      },
    );
  }

  void _toggleSelection(int key) {
    setState(() {
      if (_selectedIds.contains(key)) {
        _selectedIds.remove(key);
      } else {
        _selectedIds.add(key);
      }
      _selectionMode = _selectedIds.isNotEmpty;
    });
  }

  Future<void> _deleteSelected(BuildContext context) async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir transações'),
        content: Text(
            'Tem certeza que deseja excluir ${_selectedIds.length} transação(ões)?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            child: const Text('Excluir'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final box = Hive.box<Transaction>('transactions');
    for (final key in _selectedIds) {
      await box.delete(key);
    }

    setState(() {
      _selectedIds.clear();
      _selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {

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


    return PageView.builder(
      controller: _controller,
        
      onPageChanged: (index) {
        final currentMonth = _monthForIndex(index);
        widget.onMonthChanged?.call(currentMonth); // ✅ notifica o HomePage
      },
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final monthDate = _monthForIndex(index);
        final monthName = DateFormat('MMMM yyyy', 'pt_BR').format(monthDate);

        return Column(
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
              child: ValueListenableBuilder<Box<Transaction>>(
                valueListenable:
                    Hive.box<Transaction>('transactions').listenable(),
                builder: (context, box, _) {
                  final transactions = box.values
                      .where((t) =>
                          t.dt_transacao.month == monthDate.month &&
                          t.dt_transacao.year == monthDate.year)
                      .toList();

                  transactions.sort(
                      (a, b) => b.dt_transacao.compareTo(a.dt_transacao));

                  final double total = transactions.fold(
                      0.0, (sum, item) => sum + item.valor);

                  if (transactions.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma transação neste mês 🗓️',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              itemCount: transactions.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];
                                final isPositive = transaction.valor > 0;
                                final color = isPositive ? Colors.green : Colors.red;
                                final key = transaction.key as int;

                                final selected = _selectedIds.contains(key);

                                return InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onLongPress: () => _toggleSelection(key),
                                  onTap: () {
                                    if (_selectionMode) {
                                      _toggleSelection(key);
                                    } else {
                                      _showTransactionModal(transaction, monthDate);
                                    }
                                  },
                                  child: Card(
                                    elevation: selected ? 4 : 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: selected
                                          ? BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 2,
                                            )
                                          : BorderSide.none,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      color.withAlpha(38),
                                                  child: Icon(
                                                    isPositive
                                                        ? Icons.arrow_upward
                                                        : Icons.arrow_downward,
                                                    color: color,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        transaction.descricao,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(transaction
                                                                .dt_transacao),
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_selectionMode)
                                            Checkbox(
                                              value: selected,
                                              onChanged: (_) =>
                                                  _toggleSelection(key),
                                            )
                                          else
                                            Text(
                                              'R\$ ${transaction.valor.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total do Mês:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                Text(
                                  'R\$ ${total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: total >= 0
                                        ? Colors.blue
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_selectionMode)
                        Positioned(
                          bottom: 90,
                          right: 16,
                          child: FloatingActionButton.extended(
                            backgroundColor: Colors.redAccent,
                            icon: const Icon(Icons.delete),
                            label: Text(
                                'Excluir (${_selectedIds.length})'),
                            onPressed: () => _deleteSelected(context),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
