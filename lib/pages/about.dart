import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/icone.png',
                    height: 64,
                    width: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Controle Financeiro',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'v1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Este aplicativo foi desenvolvido para ajudar você a controlar seus gastos e ganhos de forma simples e eficiente, permitindo o registro de transações, organização mensal e visualização dos seus dados.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Funcionalidades:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('• Adicione, edite e exclua transações financeiras.'),
            const Text('• Visualize saldo mensal e histórico de transações.'),
            const Text('• Interface intuitiva e fácil de usar.'),
            const SizedBox(height: 24),
            const Text(
              'Desenvolvido por:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text('Julio André C. Faria'),
            const SizedBox(height: 24),
            const Text(
              'Contato:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text('Email: juliocibin@gmail.com'),
          ],
        ),
      ),
    );
  }
}
