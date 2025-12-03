import 'package:financas_app/models/group.dart';
import 'package:financas_app/models/transaction.dart';
import 'package:financas_app/pages/group_details_page.dart';
import 'package:financas_app/widgets/add_group_form.dart';
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

  void _showAddGroupModal(DateTime currentMonth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddGroupForm(defaultDate: currentMonth);
      },
    );
  }

  void _showAddOptions(DateTime currentMonth) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.add_task),
              title: const Text('Nova Transação'),
              onTap: () {
                Navigator.pop(context);
                _showTransactionModal(null, currentMonth);
              },
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder),
              title: const Text('Criar Grupo'),
              onTap: () {
                Navigator.pop(context);
                _showAddGroupModal(currentMonth);
              },
            ),
          ],
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
                builder: (context, transactionBox, _) {
                  return ValueListenableBuilder<Box<Group>>(
                    valueListenable: Hive.box<Group>('groups').listenable(),
                    builder: (context, groupBox, _) {
                      final transactions = transactionBox.values
                          .where((t) =>
                              t.dt_transacao.month == monthDate.month &&
                              t.dt_transacao.year == monthDate.year)
                          .toList();

                      final groups = groupBox.values
                          .where((g) =>
                              g.creationDate.month == monthDate.month &&
                              g.creationDate.year == monthDate.year)
                          .toList();

                      final List<dynamic> items = [...transactions, ...groups];

                      items.sort((a, b) {
                        final dateA = a is Transaction
                            ? a.dt_transacao
                            : (a as Group).creationDate;
                        final dateB = b is Transaction
                            ? b.dt_transacao
                            : (b as Group).creationDate;
                        return dateB.compareTo(dateA);
                      });

                      final double total = transactions.fold(
                          0.0, (sum, item) => sum + item.valor);

                      return Stack(
                        children: [
                          Column(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final item = items[index];

                                    if (item is Group) {
                                      final group = item;
                                      return InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  GroupDetailsPage(group: group),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                                            Colors.grey.withAlpha(38),
                                                        child: const Icon(
                                                          Icons.folder,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              group.name,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight.w600,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              DateFormat('dd/MM/yyyy')
                                                                  .format(group
                                                                      .creationDate),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .grey,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    final transaction = item as Transaction;
                                    final isPositive = transaction.valor > 0;
                                    final color =
                                        isPositive ? Colors.green : Colors.red;
                                    final key = transaction.key as int;

                                    final selected =
                                        _selectedIds.contains(key);

                                    return InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onLongPress: () =>
                                          _toggleSelection(key),
                                      onTap: () {
                                        if (_selectionMode) {
                                          _toggleSelection(key);
                                        } else {
                                          _showTransactionModal(
                                              transaction, monthDate);
                                        }
                                      },
                                      child: Card(
                                        elevation: selected ? 4 : 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                                            : Icons
                                                                .arrow_downward,
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
                                                            transaction
                                                                .descricao,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            DateFormat('dd/MM/yyyy')
                                                                .format(transaction
                                                                    .dt_transacao),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
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
                                                    fontWeight:
                                                        FontWeight.bold,
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
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      offset: Offset(0, -2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                           Positioned(
                            bottom: 90,
                            right: 16,
                            child: FloatingActionButton.extended(
                              backgroundColor: _selectionMode
                                  ? Colors.redAccent
                                  : Colors.greenAccent, // Cor alterada
                              icon: Icon(_selectionMode ? Icons.delete : Icons.add),
                              label: Text(_selectionMode
                                  ? 'Excluir (${_selectedIds.length})'
                                  : 'Adicionar'),
                              onPressed: () {
                                if (_selectionMode) {
                                  _deleteSelected(context);
                                } else {
                                  _showAddOptions(monthDate);
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
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
