import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../helpers/hive_helper.dart';
import '../models/transaction.dart';

class AddTransactionForm extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionForm({super.key, this.transaction});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _hiveHelper = HiveHelper();
  late bool _isGain;
  late DateTime _selectedDate;
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _isGain = widget.transaction!.valor > 0;
      _selectedDate = widget.transaction!.dt_transacao;
      _descriptionController.text = widget.transaction!.descricao;
      _valueController.text = widget.transaction!.valor.abs().toStringAsFixed(2).replaceAll('.', ',');
    } else {
      _isGain = false;
      _selectedDate = DateTime.now();
    }
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  Future<void> _saveTransaction() async {
    final value = double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0.0;
    final finalValue = _isGain ? value : -value;

    if (widget.transaction != null) {
      widget.transaction!.descricao = _descriptionController.text;
      widget.transaction!.valor = finalValue;
      widget.transaction!.dt_transacao = _selectedDate;
      await widget.transaction!.save();
    } else {
      final newTransaction = Transaction()
        ..descricao = _descriptionController.text
        ..valor = finalValue
        ..dt_transacao = _selectedDate;
      await _hiveHelper.addTransaction(newTransaction);
    }

    Navigator.of(context).pop();
  }

  Future<void> _deleteTransaction() async {
    if (widget.transaction != null) {
      await widget.transaction!.delete();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.transaction == null ? 'Adicionar Transação' : 'Editar Transação',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _valueController,
            decoration: const InputDecoration(labelText: 'Valor'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d+([,.]\d{0,2})?$')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Gasto'),
              Switch(value: _isGain, onChanged: (value) => setState(() => _isGain = value)),
              const Text('Ganho'),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(labelText: 'Data', suffixIcon: Icon(Icons.calendar_today)),
            readOnly: true,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                  context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2101));
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                  _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
                });
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descrição')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveTransaction,
            child: Text(widget.transaction == null ? 'Adicionar' : 'Salvar'),
          ),
          if (widget.transaction != null)
            ElevatedButton(
              onPressed: _deleteTransaction,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
