import 'package:financas_app/models/transaction.dart';
import 'package:financas_app/widgets/add_transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class MonthCarousel extends StatefulWidget {
  const MonthCarousel({super.key});

  @override
  State<MonthCarousel> createState() => _MonthCarouselState();
}

class _MonthCarouselState extends State<MonthCarousel> {
  late PageController _controller;
  final int _initialPage = 10000; // para simular “infinito”
  late DateTime _baseMonth;

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

  void _showTransactionModal(Transaction? transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddTransactionForm(transaction: transaction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
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
                valueListenable: Hive.box<Transaction>('transactions').listenable(),
                builder: (context, box, _) {
                  final transactions = box.values.where((t) =>
                  t.dt_transacao.month == monthDate.month &&
                      t.dt_transacao.year == monthDate.year).toList();

                  transactions.sort((a, b) => b.dt_transacao.compareTo(a.dt_transacao));

                  final double total = transactions.fold(0.0, (sum, item) => sum + item.valor);

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return ListTile(
                              title: Text(transaction.descricao),
                              subtitle: Text(DateFormat('dd/MM/yyyy').format(transaction.dt_transacao)),
                              trailing: Text('R\$ ${transaction.valor.toStringAsFixed(2)}',
                                style: TextStyle(color: transaction.valor > 0 ? Colors.green : Colors.red),
                              ),
                              onTap: () => _showTransactionModal(transaction),
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
                              )
                            ]
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total do Mês:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              'R\$ ${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: total >= 0 ? Colors.blue : Colors.red,
                              ),
                            ),
                          ],
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
