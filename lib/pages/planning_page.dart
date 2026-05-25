import 'package:flutter/material.dart';
import 'package:financas_app/data/datasources/local/goal_datasource.dart';
import 'package:financas_app/models/goal.dart';
import 'package:financas_app/widgets/forms/goal_form.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  final _goalDataSource = GoalDataSource();
  late Future<List<Goal>> _goalsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _goalsFuture = _goalDataSource.getAll();
    });
  }

  void _showGoalForm({Goal? goal}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => GoalForm(goal: goal),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Goal>>(
        future: _goalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final goals = snapshot.data ?? [];

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: goals.length + 1,
            itemBuilder: (context, index) {
              if (index == goals.length) {
                return _addCard(context);
              }
              return _goalCard(context, goals[index]);
            },
          );
        },
      ),
    );
  }

  Widget _addCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showGoalForm(),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 36),
            SizedBox(height: 8),
            Text('Nova Meta', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _goalCard(BuildContext context, Goal goal) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showGoalForm(goal: goal),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              FutureBuilder<Map<String, double>>(
                future: _goalDataSource.getGoalProgress(goal.id),
                builder: (context, snapshot) {
                  final current = snapshot.data?['currentAmount'] ?? 0.0;
                  final progress = goal.targetValue > 0
                      ? (current / goal.targetValue).clamp(0.0, 1.0)
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
                      const SizedBox(height: 6),
                      Text(
                        'R\$ ${current.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'de R\$ ${goal.targetValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
