import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthCarousel extends StatefulWidget {
  const MonthCarousel({super.key});

  @override
  State<MonthCarousel> createState() => _MonthCarouselState();
}

class _MonthCarouselState extends State<MonthCarousel> {
  late PageController _controller;
  final int _initialPage = 10000; // para simular “infinito”
  late DateTime _baseMonth;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _initialPage);
    _baseMonth = DateTime.now();
  }

  DateTime _monthForIndex(int index) {
    int diff = index - _initialPage;
    return DateTime(_baseMonth.year, _baseMonth.month + diff);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final monthDate = _monthForIndex(index);
        final monthName = DateFormat('MMMM yyyy', 'pt_BR').format(monthDate);

        return Center(
          child: Text(
            monthName[0].toUpperCase() + monthName.substring(1),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
