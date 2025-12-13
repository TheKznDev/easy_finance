import 'package:financas_app/data/datasources/local/group_datasource.dart';
import 'package:financas_app/models/group.dart';
import 'package:financas_app/pages/group_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupForm extends StatefulWidget {
  final DateTime defaultDate;

  const GroupForm({Key? key, required this.defaultDate}) : super(key: key);

  @override
  _GroupFormState createState() => _GroupFormState();
}

class _GroupFormState extends State<GroupForm> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  String? _nameError, _valueError;

  final _groupDataSource = GroupDataSource();

  Future<void> _saveGroup() async {
    final name = _nameController.text.trim();

    setState(() {
      _nameError = null;
    });

    bool hasError = false;
    if (name.isEmpty) {
      setState(() {
        _nameError = 'O nome do grupo é obrigatório.';
      });
      hasError = true;
    }

    if (hasError) return;

    final newGroup = Group(
      name: name,
      creationDate: widget.defaultDate,
    );

    try {
      await _groupDataSource.insert(newGroup);

      if (!mounted) return; // Garante que o widget ainda está na árvore

      Navigator.of(context).pop(); // Fecha o modal

      //Exibe a snackbar de grupo criado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Grupo "$name" criado!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar grupo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Criar Novo Grupo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop()),
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
