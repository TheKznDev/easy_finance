import 'package:financas_app/pages/about.dart';
import 'package:financas_app/pages/help.dart';
import 'package:financas_app/utils/csv_export.dart';
import 'package:financas_app/widgets/toggle_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      // {
      //   'icon': Icons.upload_file,
      //   'title': 'Exportar dados',
      //   'subtitle': 'Salve seus registros em CSV',
      //   'onTap': () => _showSnack(context, 'Exportar dados'),
      // },
      {
        'icon': Icons.dark_mode,
        'title': 'Modo escuro',
        'subtitle': 'Ative o tema escuro do app',
        'onTap': () => _showSnack(context, 'Modo escuro'),
      },
      {
        'icon': Icons.help_outline,
        'title': 'Ajuda',
        'subtitle': 'Guia de uso e dúvidas frequentes',
        'onTap': () => _showSnack(context, 'Ajuda'),
      },
      {
        'icon': Icons.info_outline,
        'title': 'Sobre o aplicativo',
        'subtitle': 'Versão e informações do desenvolvedor',
        'onTap': () => _showSnack(context, 'Sobre o aplicativo'),
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(
              item['icon'] as IconData,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(item['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(item['subtitle'] as String),
          trailing: const Icon(Icons.chevron_right),
          onTap: item['onTap'] as VoidCallback,
        );
      },
    );
  }

  static void _showSnack(BuildContext context, String text) {

    switch (text) {

      case "Sobre o aplicativo":
        Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
        break;

      case "Modo escuro":
        showToggleDarkModeDialog(
          context: context,
          currentThemeMode: Theme.of(context).brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
          onThemeModeChanged: (ThemeMode mode) {

            // INSERIR: Definir o modo de tema do app.
            final root = context.findAncestorStateOfType<NavigatorState>()?.context ?? context;
            // Encontrar o ancestor MaterialApp para acessar o ThemeMode
            // Aqui, usamos InheritedWidget para alterar tema dinamicamente, mas como o MaterialApp foi instanciado com ThemeMode.system hardcoded,
            // é preciso usar um gerenciador de estado global em produção. Para fins didáticos/temporários:
            // ScaffoldMessenger para informar ao usuário (comente/remova se usar provider/get)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Modo de tema alterado para: ${mode.name} (requer reinício)')),
            );

          },
        );
        break;

        case "Exportar dados":
          FilePicker.platform.saveFile(
            dialogTitle: 'Salvar CSV Exportado',
            fileName: 'transacoes_export_${DateTime.now().millisecondsSinceEpoch}.csv',
            type: FileType.custom,
            allowedExtensions: ['csv'],
          ).then((selectedPath) async {
            if (selectedPath != null) {
              try {
                final filePath = await exportAllTransactionsToCsv(selectedPath);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Arquivo exportado com sucesso:\n$filePath')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao exportar CSV: $e')),
                );
              }
            }
          });
          break;

      case "Ajuda":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HelpPage()),
        );
        break;


      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$text em breve...')),
        );
        break;
      
    }
  }
}
