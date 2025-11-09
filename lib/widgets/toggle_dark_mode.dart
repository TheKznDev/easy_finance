import 'package:flutter/material.dart';

/// Um popup para seleção de tema escuro, claro ou do sistema.
/// Utilize `showToggleDarkModeDialog` abaixo para exibir esta janela.
class ToggleDarkModePopup extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const ToggleDarkModePopup({
    Key? key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  }) : super(key: key);

  @override
  State<ToggleDarkModePopup> createState() => _ToggleDarkModePopupState();
}

class _ToggleDarkModePopupState extends State<ToggleDarkModePopup> {
  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.currentThemeMode;
  }

  @override
  Widget build(BuildContext context) {
    // Popup estilizado como janela com borderRadius e sombra.
    return Center(
      child: Material(
        elevation: 24,
        color: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                color: Colors.black.withOpacity(0.18),
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecione o tema',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                groupValue: _selectedMode,
                title: const Text("Sistema"),
                secondary: const Icon(Icons.settings),
                onChanged: (val) {
                  setState(() { _selectedMode = val!; });
                },
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: _selectedMode,
                title: const Text("Escuro"),
                secondary: const Icon(Icons.dark_mode),
                onChanged: (val) {
                  setState(() { _selectedMode = val!; });
                },
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: _selectedMode,
                title: const Text("Claro"),
                secondary: const Icon(Icons.light_mode),
                onChanged: (val) {
                  setState(() { _selectedMode = val!; });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    child: const Text('OK'),
                    onPressed: () {
                      widget.onThemeModeChanged(_selectedMode);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Função utilitária para abrir a janela popup de tema.
/// Exemplo de uso:
/// 
/// ```dart
/// showToggleDarkModeDialog(
///   context: context,
///   currentThemeMode: ThemeMode.system,
///   onThemeModeChanged: (mode) { ... }
/// );
/// ```
Future<void> showToggleDarkModeDialog({
  required BuildContext context,
  required ThemeMode currentThemeMode,
  required ValueChanged<ThemeMode> onThemeModeChanged,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => ToggleDarkModePopup(
      currentThemeMode: currentThemeMode,
      onThemeModeChanged: onThemeModeChanged,
    ),
  );
}
