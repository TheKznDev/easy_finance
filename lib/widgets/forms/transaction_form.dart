import 'package:financas_app/data/datasources/local/goal_datasource.dart';
import 'package:financas_app/data/datasources/local/transaction_datasource.dart';
import 'package:financas_app/models/goal.dart';
import 'package:financas_app/models/group.dart';
import 'package:financas_app/widgets/forms/group_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../data/datasources/local/group_datasource.dart';
import '../../models/transaction.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? transaction;
  final DateTime? defaultMonth;

  const TransactionForm({super.key, this.transaction, this.defaultMonth});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _transactionDataSource = TransactionDataSource();
  final _goalDataSource = GoalDataSource();
  final _groupDataSource = GroupDataSource();

  late TransactionType _transactionType;
  late DateTime _selectedDate;
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  String? _descriptionError, _valueError;
  String? _selectedGoalId, _selectedGroupId;
  late Future<List<Goal>> _goalsFuture;
  late Future<List<Group>> _groupsFuture;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _loadFutures();

    if (_isEditing) {
      final t = widget.transaction!;
      _transactionType = t.type;
      _selectedDate = t.date;
      _descriptionController.text = t.description;
      _valueController.text = t.value.toStringAsFixed(2).replaceAll('.', ',');
      _selectedGoalId = t.goalId;
      _selectedGroupId = t.groupId;
      final centavos = (t.value * 100).toInt().toString();
      // dispara o formatter manualmente
      _valueController.value = _CurrencyInputFormatter().formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: centavos),
      );
    } else {
      _transactionType = TransactionType.expense;
      _selectedDate = widget.defaultMonth != null
          ? DateTime(
              widget.defaultMonth!.year,
              widget.defaultMonth!.month,
              DateTime.now().day,
            )
          : DateTime.now();
    }

    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  void _loadFutures() {
    _goalsFuture = _goalDataSource.getAll();
    _groupsFuture = _groupDataSource.getAll();
  }

  // Recarrega a lista de grupos, usado após adicionar um novo grupo
  void _refreshGroupList() {
    setState(() {
      _groupsFuture = _groupDataSource.getAll();
    });
  }

  // Mostra o formulário para adicionar um novo grupo
  void _showAddGroupForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // Passa a data selecionada para que o novo grupo seja criado no contexto certo
        return GroupForm(defaultDate: _selectedDate);
      },
    ).then((_) => _refreshGroupList()); // Atualiza a lista após fechar
  }

  Future<void> _saveTransaction() async {
    final valueText = _valueController.text.trim();
    final descriptionText = _descriptionController.text.trim();

    setState(() {
      _descriptionError = null;
      _valueError = null;
    });

    final value = double.tryParse(
      valueText.replaceAll('.', '').replaceAll(',', '.'),
    );

    if (value == null || value <= 0) {
      setState(() => _valueError = 'Informe um valor maior que zero');
      return;
    }

    if (descriptionText.isEmpty) {
      setState(() => _descriptionError = 'A descrição não pode estar vazia.');
      return;
    }

    try {
      if (_isEditing) {
        final updatedTransaction = widget.transaction!.copyWith(
          description: descriptionText,
          value: value,
          date: _selectedDate,
          type: _transactionType,
          goalId: _selectedGoalId,
          groupId: _selectedGroupId,
        );
        await _transactionDataSource.update(updatedTransaction);
      } else {
        final newTransaction = Transaction(
          description: descriptionText,
          value: value,
          date: _selectedDate,
          type: _transactionType,
          goalId: _selectedGoalId,
          groupId: _selectedGroupId,
        );
        await _transactionDataSource.insert(newTransaction);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar transação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTransaction() async {
    if (_isEditing) {
      try {
        await _transactionDataSource.delete(widget.transaction!.id);
        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir transação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Editar Transação' : 'Adicionar Transação',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
                errorText: _valueError,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CurrencyInputFormatter(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Gasto'),
                Switch(
                  value: _transactionType == TransactionType.income,
                  onChanged: (value) => setState(
                    () => _transactionType = value
                        ? TransactionType.income
                        : TransactionType.expense,
                  ),
                ),
                const Text('Ganho'),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Data',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                    _dateController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(_selectedDate);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                errorText: _descriptionError,
              ),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Mais Opções'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 20),
              children: [
                Column(
                  children: [
                    FutureBuilder<List<Goal>>(
                      future: _goalsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final goals = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          value: _selectedGoalId,
                          decoration: const InputDecoration(
                            labelText: 'Vincular à Meta',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Nenhuma'),
                            ),
                            ...goals.map((goal) {
                              return DropdownMenuItem<String>(
                                value: goal.id,
                                child: Text(goal.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGoalId = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Group>>(
                      future: _groupsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final groups = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedGroupId,
                              decoration: const InputDecoration(
                                labelText: 'Vincular ao Grupo',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Nenhum'),
                                ),
                                ...groups.map((group) {
                                  return DropdownMenuItem<String>(
                                    value: group.id,
                                    child: Text(group.name),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedGroupId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _showAddGroupForm,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text(
                                  'Novo Grupo',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_isEditing) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: _deleteTransaction,
                      child: const Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    child: Text(_isEditing ? 'Salvar' : 'Adicionar'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final intValue = int.parse(digits);
    final formatted = _format(intValue.toString());

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(String digits) {
    // Adiciona vírgula nos últimos 2 dígitos
    var value = digits.replaceAllMapped(RegExp(r'(\d{2})$'), (m) => ',${m[1]}');

    // Adiciona ponto para milhar
    if (value.length > 6) {
      value = value.replaceAllMapped(
        RegExp(r'(\d{3}),(\d{2}$)'),
        (m) => '.${m[1]},${m[2]}',
      );
    }

    return value;
  }
}
