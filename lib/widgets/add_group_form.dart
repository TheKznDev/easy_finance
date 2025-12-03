import 'package:financas_app/models/group.dart';
import 'package:financas_app/pages/group_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class AddGroupForm extends StatefulWidget {
  final DateTime defaultDate;

  const AddGroupForm({Key? key, required this.defaultDate}) : super(key: key);

  @override
  _AddGroupFormState createState() => _AddGroupFormState();
}

class _AddGroupFormState extends State<AddGroupForm> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  String? _nameError, _valueError;

  Future<void> _saveGroup() async {
    final name = _nameController.text.trim();
    final value = double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0.0;

    setState(() {
      _nameError = null;
      _valueError = null;
    });

    bool hasError = false;
    if (name.isEmpty) {
      setState(() {
        _nameError = 'O nome do grupo é obrigatório.';
      });
      hasError = true;
    }
    if (value <= 0) {
      setState(() {
        _valueError = 'O valor deve ser maior que zero.';
      });
      hasError = true;
    }

    if (hasError) return;

    final newGroup = Group()
      ..name = name
      ..targetValue = value
      ..creationDate = widget.defaultDate;

    final box = Hive.box<Group>('groups');
    await box.add(newGroup);

    if (!mounted) return; // Garante que o widget ainda está na árvore

    Navigator.of(context).pop(); // Fecha o modal

    // Navega para a tela de detalhes com o novo grupo
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupDetailsPage(group: newGroup),
      ),
    );
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
              const Text('Criar Novo Grupo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome do Grupo',
              errorText: _nameError,
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _valueController,
            decoration: InputDecoration(
              labelText: 'Valor da Meta',
              errorText: _valueError,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+([,.]\d{0,2})?$')),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveGroup,
            child: const Text('Criar Grupo'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
