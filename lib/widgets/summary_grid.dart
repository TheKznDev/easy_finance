import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../pages/month_carousel_page.dart';
import 'dashboard_card.dart';

class SummaryGrid extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> summaryFuture;
  final Color accentColor;
  final VoidCallback? onRefresh;

  const SummaryGrid({
    super.key,
    required this.summaryFuture,
    required this.accentColor,
    type, this.onRefresh
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 180,
            child: Center(
              child: Text('Erro ao carregar resumo: ${snapshot.error}'),
            ),
          );
        }

        final groups = snapshot.data ?? [];

        final List<Widget> cards = [
          DashboardCard(
            title: 'Extrato Mensal',
            icon: Icon(
              Icons.calendar_month,
              size: 32,
              color: accentColor,
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MonthCarouselPage(),
                ),
              );

              onRefresh?.call();
            },
          ),
        ];

        cards.addAll(
          groups.map((group) {
            final value = NumberFormat.simpleCurrency(locale: 'pt_BR')
                .format(group['total']);

            return DashboardCard(
              title: group['name'],
              value: value,
            );
          }),
        );

        return GridView.count(
          padding: const EdgeInsets.all(8),
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cards,
        );
      },
    );
  }
}
