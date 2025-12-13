import 'package:flutter/material.dart';
import 'package:financas_app/models/group.dart';

import '../data/datasources/local/group_datasource.dart';

Future<String?> showGroupSelectModal(BuildContext context) {
  return showModalBottomSheet<String?>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const _GroupSelectModal(),
  );
}

class _GroupSelectModal extends StatefulWidget {
  const _GroupSelectModal();

  @override
  State<_GroupSelectModal> createState() => _GroupSelectModalState();
}

class _GroupSelectModalState extends State<_GroupSelectModal> {
  final _groupDataSource = GroupDataSource();

  late Future<List<Group>> _groupsFuture;
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _groupDataSource.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<Group>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data ?? [];

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selecionar Grupo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String?>(
                value: _selectedGroupId,
                decoration: const InputDecoration(
                  labelText: 'Grupo',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Nenhum'),
                  ),
                  ...groups.map(
                        (group) => DropdownMenuItem<String?>(
                      value: group.id,
                      child: Text(group.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedGroupId = value);
                },
              ),

              const SizedBox(height: 16),


              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedGroupId);
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
