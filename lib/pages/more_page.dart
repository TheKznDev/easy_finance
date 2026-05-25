import 'package:financas_app/pages/about.dart';
import 'package:financas_app/pages/help.dart';
import 'package:financas_app/utils/csv_export.dart';
import 'package:financas_app/utils/import.dart';
import 'package:financas_app/utils/theme_manager.dart';
import 'package:financas_app/widgets/toggle_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Login
        _buildSectionHeader('Conta'),
        _buildItem(
          context,
          icon: Icons.cloud_upload,
          label: 'Fazer Login',
          subtitle: 'Sincronizar na nuvem',
          onTap: () {},
        ),

        _buildSectionHeader('Dados'),
        _buildItem(
          context,
          icon: Icons.upload,
          label: 'Importar CSV',
          onTap: () => ImportUtils.importarTransacoesCsv(context),
        ),
        _buildItem(
          context,
          icon: Icons.download,
          label: 'Exportar CSV',
          onTap: () => _showExportOptions(context),
        ),

        _buildSectionHeader('Aparência'),
        _buildItem(
          context,
          icon: Icons.dark_mode,
          label: 'Tema',
          onTap: () => showToggleDarkModeDialog(
            context: context,
            currentThemeMode: themeManager.themeModeNotifier.value,
            onThemeModeChanged: (mode) => themeManager.setThemeMode(mode),
          ),
        ),

        _buildSectionHeader('Suporte'),
        _buildItem(
          context,
          icon: Icons.help_outline,
          label: 'Ajuda',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpPage()),
          ),
        ),
        _buildItem(
          context,
          icon: Icons.info_outline,
          label: 'Sobre',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutPage()),
          ),
        ),

        const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Versão 1.0.0',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Salvar no dispositivo'),
              onTap: () {
                Navigator.pop(context);
                _exportAndSave(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartilhar'),
              onTap: () {
                Navigator.pop(context);
                _exportAndShare(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAndShare(BuildContext context) async {
    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/transacoes_${DateTime.now().millisecondsSinceEpoch}.csv';
      await exportAllTransactionsToCsv(path);
      await Share.shareXFiles([
        XFile(path),
      ], text: 'Minhas transações exportadas');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _exportAndSave(BuildContext context) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar CSV',
      fileName: 'transacoes_${DateTime.now().millisecondsSinceEpoch}.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (path == null) return;
    try {
      await exportAllTransactionsToCsv(path);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CSV salvo com sucesso')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }
}
