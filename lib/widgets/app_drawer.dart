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

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // HEADER
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF43A047),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: const [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Usuário',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Modo Offline',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // MENU ITEMS SIMPLIFICADOS
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSectionHeader('Dados'),
                _buildDrawerItem(
                  context,
                  icon: Icons.upload,
                  title: 'Importar CSV',
                  onTap: () => ImportUtils.importarTransacoesCsv(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.download,
                  title: 'Exportar CSV',
                  onTap: () => _showExportOptions(context),
                ),

                _buildSectionHeader('Aparência'),
                _buildDrawerItem(
                  context,
                  icon: Icons.dark_mode,
                  title: 'Tema',
                  onTap: () => _showThemeDialog(context),
                ),

                _buildSectionHeader('Sobre'),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Ajuda',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpPage()),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'Sobre',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  ),
                ),
              ],
            ),
          ),

          // FOOTER
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.cloud_upload, color: Colors.blue[600]),
            title: Text(
              'Fazer Login',
              style: TextStyle(
                color: Colors.blue[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              // Navegar para login
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Versão 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
    FilePicker.platform.saveFile(
      dialogTitle: 'Salvar CSV',
      fileName: 'transacoes_${DateTime.now().millisecondsSinceEpoch}.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    ).then((selectedPath) async {
      if (selectedPath != null) {
        try {
          final filePath = await exportAllTransactionsToCsv(selectedPath);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exportado com sucesso:\n$filePath')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    });
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
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
        );
      },
    );
  }

  Future<void> _exportAndShare(BuildContext context) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/transacoes_${DateTime.now().millisecondsSinceEpoch}.csv';

      await exportAllTransactionsToCsv(filePath);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Minhas transações exportadas',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao compartilhar CSV: $e')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV salvo com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar CSV: $e')),
      );
    }
  }


}
