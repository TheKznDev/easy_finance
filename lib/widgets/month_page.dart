import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/datasources/local/transaction_datasource.dart';
import '../models/transaction.dart';

import 'package:financas_app/widgets/forms/transaction_form.dart';

import 'group_modal.dart';

class MonthPage extends StatefulWidget {
  final DateTime monthDate;
  final TransactionDataSource dataSource;

  const MonthPage({
    super.key,
    required this.monthDate,
    required this.dataSource,
  });

  @override
  State<MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage>
    with AutomaticKeepAliveClientMixin {
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // obrigatório

    return Scaffold(
      body: _buildContent(),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: _selectionMode ? _buildDeleteFab() : _buildAddFab(),
    );
  }

  Future<List<Transaction>> _getTransactionsForMonth() async {
    final start = DateTime(widget.monthDate.year, widget.monthDate.month, 1);
    final end = DateTime(widget.monthDate.year, widget.monthDate.month + 1, 0);

    final list = await widget.dataSource.findByPeriod(start, end);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Widget _buildDeleteFab() {
    return FloatingActionButton(
      backgroundColor: Colors.redAccent,
      onPressed: () => _deleteSelected(context),
      child: const Icon(Icons.delete),
    );
  }

  Widget _buildAddFab() {
    return FloatingActionButton(
      backgroundColor: Colors.greenAccent,
      onPressed: () => _showTransactionModal(null, widget.monthDate),
      child: const Icon(Icons.add),
    );
  }

  Widget? _buildBottomBar() {
    return FutureBuilder<List<Transaction>>(
      future: _getTransactionsForMonth(),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? [];

        final total = transactions.fold<double>(
          0,
          (sum, t) =>
              sum + (t.type == TransactionType.income ? t.value : -t.value),
        );

        return _selectionMode
            ? _buildSelectionBar()
            : BottomAppBar(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Saldo do Mês',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'R\$ ${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: total >= 0 ? Colors.blue : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }

  Widget _buildContent() {
    final monthName = DateFormat('MMMM yyyy', 'pt_BR').format(widget.monthDate);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            monthName[0].toUpperCase() + monthName.substring(1),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Transaction>>(
            future: _getTransactionsForMonth(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink(); // 🔥 NÃO pisca
              }

              final transactions = snapshot.data ?? [];

              if (transactions.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma transação neste mês.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) =>
                    _buildTransactionTile(transactions[index]),
              );
            },
          ),
        ),
      ],
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  Future<void> _deleteSelected(BuildContext context) async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Transações'),
        content: Text(
          'Tem certeza que deseja excluir ${_selectedIds.length} transação(ões)?',
        ),
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

    for (final id in _selectedIds) {
      await widget.dataSource.delete(id);
    }

    setState(() {
      _selectedIds.clear();
      _selectionMode = false;
    });
  }

  void _showTransactionModal(Transaction? transaction, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return TransactionForm(transaction: transaction, defaultMonth: date);
      },
    ).then((_) {
      setState(() {}); // força refresh após salvar
    });
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

  Widget _buildSelectionBar() {
    return BottomAppBar(
      color: Colors.blue.shade700,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
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
            const Spacer(),
            TextButton(
              onPressed: () async {
                final groupId = await showGroupSelectModal(context);

                if (groupId == null) return;

                for (final id in _selectedIds) {
                  await widget.dataSource.updateGroup(
                    transactionId: id,
                    groupId: groupId,
                  );
                }

                setState(() {
                  _selectedIds.clear();
                  _selectionMode = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transações adicionadas ao grupo'),
                  ),
                );
              },
              child: const Text(
                'Adicionar ao grupo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
