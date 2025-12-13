import 'package:flutter/material.dart';
import 'package:financas_app/data/datasources/local/goal_datasource.dart';
import 'package:financas_app/models/goal.dart';
import 'package:financas_app/widgets/forms/goal_form.dart';

class GoalsSection extends StatelessWidget {
  final Future<List<Goal>> goalsFuture;
  final GoalDataSource goalDataSource;
  final VoidCallback onRefresh;

  const GoalsSection({
    super.key,
    required this.goalsFuture,
    required this.goalDataSource,
    required this.onRefresh,
  });

  void _showGoalForm(BuildContext context, {Goal? goal}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => GoalForm(goal: goal),
    );
    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Goal>>(
      future: goalsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 150,
            child: Center(
              child: Text('Erro ao carregar metas: ${snapshot.error}'),
            ),
          );
        }

        final goals = snapshot.data ?? [];

        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: goals.length + 1,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              if (index == goals.length) {
                return _addGoalCard(context);
              }

              final goal = goals[index];
              return _goalCard(context, goal);
            },
          ),
        );
      },
    );
  }

  Widget _addGoalCard(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showGoalForm(context),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 40),
              SizedBox(height: 8),
              Text('Adicionar Meta'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goalCard(BuildContext context, Goal goal) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          onTap: () => _showGoalForm(context, goal: goal),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                FutureBuilder<Map<String, double>>(
                  future: goalDataSource.getGoalProgress(goal.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }

                    if (!snapshot.hasData || snapshot.hasError) {
                      return const Text(
                        'Erro',
                        style: TextStyle(color: Colors.red),
                      );
                    }

                    final currentAmount =
                        snapshot.data!['currentAmount'] ?? 0.0;

                    final progress = goal.targetValue > 0
                        ? currentAmount / goal.targetValue
                        : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${currentAmount.toStringAsFixed(2)} / '
                              'R\$ ${goal.targetValue.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
