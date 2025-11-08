import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.upload_file,
        'title': 'Exportar dados',
        'subtitle': 'Salve seus registros em CSV',
        'onTap': () => _showSnack(context, 'Exportar dados'),
      },
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

    print(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$text em breve...')),
    );
  }
}
