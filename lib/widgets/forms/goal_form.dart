import 'package:financas_app/data/datasources/local/goal_datasource.dart';
import 'package:financas_app/data/datasources/local/transaction_datasource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/goal.dart';

class GoalForm extends StatefulWidget {
  final Goal? goal;
  const GoalForm({super.key, this.goal});

  @override
  _GoalFormState createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _deadline;
  String? _nameError, _valueError, _dateError;

  // Instancia o repositório para interagir com os dados das metas
  late final GoalDataSource _goalDataSource;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();


    if (_isEditing) {
      _nameController.text = widget.goal!.name;
      _targetController.text =
          widget.goal!.targetValue.toStringAsFixed(2).replaceAll('.', ',');
      _deadline = widget.goal!.deadline;
      _dateController.text = DateFormat('dd/MM/yyyy').format(_deadline!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      locale: const Locale('pt', 'BR'),
    );
    if (pickedDate != null && pickedDate != _deadline) {
      setState(() {
        _deadline = pickedDate;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_deadline!);
      });
    }
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState?.validate() ?? false) {
      final goalName = _nameController.text.trim();
      final goalTargetStr = _targetController.text.replaceAll(',', '.');

      setState(() {
        _nameError = null;
        _valueError = null;
        _dateError = null;
      });

      if (goalName.isEmpty) {
        setState(() => _nameError = 'Por favor, insira um nome para a meta.');
        return;
      }

      if (goalTargetStr.isEmpty ||
          double.tryParse(goalTargetStr) == null ||
          double.parse(goalTargetStr) <= 0) {
        setState(() =>
            _valueError = 'Por favor, insira um valor maior que zero.');
        return;
      }

      if (_deadline == null) {
        setState(() => _dateError = 'Por favor, selecione uma data.');
        return;
      }

      final goalTarget = double.parse(goalTargetStr);

      // Cria ou atualiza o objeto Goal
      final goalToSave = _isEditing
          ? widget.goal!.copyWith(
              name: goalName,
              targetValue: goalTarget,
              deadline: _deadline,
            )
          : Goal(
              name: goalName,
              targetValue: goalTarget,
              deadline: _deadline!,
            );

      try {
        await _goalDataSource.insert(goalToSave);
        //await _goalRepository.saveGoal(goalToSave);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Meta "$goalName" ${_isEditing ? 'atualizada' : 'salva'}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar meta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteGoal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Meta'),
        content: const Text('Tem certeza que deseja excluir esta meta?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Excluir'),
            onPressed: () async {
              Navigator.of(ctx).pop(); // close dialog
              if (_isEditing) {
                try {
                  await _goalDataSource.delete(widget.goal!.id);
                  //await _goalRepository.deleteGoal(widget.goal!.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Meta "${widget.goal!.name}" excluída!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pop(); // close bottom sheet
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao excluir meta: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Editar Meta' : 'Nova Meta',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome da Meta',
                prefixIcon: const Icon(Icons.flag_outlined),
                errorText: _nameError,
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Nome não pode ser vazio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetController,
              decoration: InputDecoration(
                labelText: 'Valor da Meta (R\$)',
                prefixIcon: const Icon(Icons.attach_money),
                errorText: _valueError,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) =>
                  value!.isEmpty ? 'Valor não pode ser vazio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Prazo',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
                errorText: _dateError,
              ),
              readOnly: true,
              onTap: _pickDate,
              validator: (value) =>
                  value!.isEmpty ? 'Data não pode ser vazia' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              label: const Text('SALVAR', style: TextStyle(fontSize: 16)),
            ),
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: _deleteGoal,
                  label: const Text(
                    'Excluir Meta',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
