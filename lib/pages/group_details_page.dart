import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/group.dart';

class GroupDetailsPage extends StatelessWidget {
  final Group group;

  const GroupDetailsPage({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lógica de exemplo para calcular o progresso.
    // No futuro, isso viria da soma de transações associadas.
    double currentAmount = 500.0; 
    double percent = (currentAmount / group.targetValue).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearPercentIndicator(
              lineHeight: 20.0,
              percent: percent,
              center: Text(
                '${(percent * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.grey.shade300,
              progressColor: Theme.of(context).colorScheme.primary,
              barRadius: const Radius.circular(10),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Alcançado: R\$${currentAmount.toStringAsFixed(2)}'),
                Text('Meta: R\$${group.targetValue.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            // Aqui será a lista de transações do grupo
            const Text('Transações do Grupo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Expanded(
              child: Center(
                child: Text('Nenhuma transação adicionada ainda.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
