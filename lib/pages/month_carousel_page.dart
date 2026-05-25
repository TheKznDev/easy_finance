import 'package:financas_app/widgets/month_carousel.dart';
import 'package:flutter/material.dart';

class MonthCarouselPage extends StatefulWidget {
  const MonthCarouselPage({super.key});

  @override
  State<MonthCarouselPage> createState() => _MonthCarouselPageState();
}

class _MonthCarouselPageState extends State<MonthCarouselPage> {
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MonthCarousel(
        onMonthChanged: (month) {
          setState(() {
            _currentMonth = month;
          });
        },
      ),
    );
  }
}
