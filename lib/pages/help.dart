import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  Widget _stepTile({
    required BuildContext context,
    required int step,
    required String title,
    required String description,
    required IconData icon,
    String? assetImage, // For future asset images
  }) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 32),
              radius: 28,
            ),
            const SizedBox(width: 16),
            Text(
              'Passo $step',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        if (assetImage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(assetImage, height: 190, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda & Guia de Uso'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: 60),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Como usar o Controle Financeiro',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 28),

            _stepTile(
              context: context,
              step: 1,
              title: 'Adicione uma transação',
              description: 'Toque no botão "+" na tela inicial para registrar um novo gasto ou ganho. '
                  'Preencha valor, tipo (gasto ou ganho), data e descrição. Depois toque em "Adicionar".',
              icon: Icons.add_circle_outline,
              assetImage: null, // exemplo: 'assets/help_add_transaction.png'
            ),
            _stepTile(
              context: context,
              step: 2,
              title: 'Navegue entre os meses',
              description: 'Deslize para os lados na parte superior da tela para mudar de mês e ver as transações daquele período.',
              icon: Icons.calendar_month,
              assetImage: null,
            ),
            _stepTile(
              context: context,
              step: 3,
              title: 'Edite ou exclua transações',
              description: 'Toque em uma transação para editar ou deslize lateralmente sobre ela para ter opções rápidas.',
              icon: Icons.edit,
              assetImage: null,
            ),
            _stepTile(
              context: context,
              step: 4,
              title: 'Veja o saldo e totais',
              description: 'O saldo do mês e o total de ganhos/gastos ficam destacados no topo para fácil acompanhamento.',
              icon: Icons.account_balance_wallet_outlined,
              assetImage: null,
            ),
            _stepTile(
              context: context,
              step: 5,
              title: 'Altere o tema (claro/escuro)',
              description: 'Acesse o menu de configurações para escolher entre tema claro, escuro ou seguir o sistema do seu aparelho.',
              icon: Icons.dark_mode,
              assetImage: null,
            ),
            _stepTile(
              context: context,
              step: 6,
              title: 'Exportar seus dados',
              description: 'No menu de configurações, use "Exportar dados" para salvar suas transações em CSV.',
              icon: Icons.upload_file,
              assetImage: null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Dúvidas frequentes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Não consigo adicionar um valor negativo. Como registrar um gasto?\n'
              '  ⇒ Use o botão "Gasto/Ganho" para definir se o valor é uma saída ou entrada.\n'
              '• Como excluo várias transações?\n'
              '  ⇒ Ative o modo de seleção por pressionamento prolongado em uma transação.\n'
              '• Posso restaurar dados apagados?\n'
              '  ⇒ Não. Por segurança, faça backup exportando.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 36),
            Center(
              child: Column(
                children: [
                  Text(
                    'Ainda precisa de ajuda?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  const Text('Envie um email: juliocibin@gmail.com'),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
