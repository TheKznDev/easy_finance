import 'package:financas_app/pages/about.dart';
import 'package:financas_app/pages/help.dart';
import 'package:financas_app/utils/csv_export.dart';
import 'package:financas_app/utils/import.dart';
import 'package:financas_app/utils/theme_manager.dart';
import 'package:financas_app/widgets/toggle_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionTitle(context, 'Dados'),
          _buildSettingsTile(
            context,
            icon: Icons.upload,
            title: 'Importar dados CSV',
            subtitle: 'Restaure seus registros a partir de um arquivo CSV',
            onTap: () => ImportUtils.importarTransacoesCsv(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.download,
            title: 'Exportar dados CSV',
            subtitle: 'Exporte seus registros para um arquivo CSV',
            onTap: () => _exportData(context),
          ),
          _buildSectionTitle(context, 'Aparência'),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode,
            title: 'Modo escuro',
            subtitle: 'Ative o tema escuro do app',
            onTap: () => _showThemeDialog(context),
          ),
          _buildSectionTitle(context, 'Sobre'),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Ajuda',
            subtitle: 'Guia de uso e dúvidas frequentes',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpPage()),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'Sobre o aplicativo',
            subtitle: 'Versão e informações do desenvolvedor',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutPage()),
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  ListTile _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showThemeDialog(BuildContext context) {
    showToggleDarkModeDialog(
      context: context,
      currentThemeMode: themeManager.themeModeNotifier.value,
      onThemeModeChanged: (ThemeMode mode) {
        themeManager.setThemeMode(mode);
      },
    );
  }

  void _exportData(BuildContext context) {
    FilePicker.platform
        .saveFile(
      dialogTitle: 'Salvar CSV Exportado',
      fileName: 'transacoes_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    )
        .then((selectedPath) async {
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
  }
}
