import 'package:financas_app/widgets/app_drawer.dart';
import 'package:financas_app/pages/overview_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visão Geral',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      drawer: const AppDrawer(),
      body: const OverviewPage(),
    );
  }
}
