import 'package:flutter/cupertino.dart';

import '../data/datasources/local/transaction_datasource.dart';
import 'month_page.dart';

class MonthCarousel extends StatefulWidget {
  final ValueChanged<DateTime>? onMonthChanged;
  const MonthCarousel({super.key, this.onMonthChanged});

  @override
  State<MonthCarousel> createState() => _MonthCarouselState();
}

class _MonthCarouselState extends State<MonthCarousel> {
  late PageController _controller;
  final int _initialPage = 10000;
  late DateTime _baseMonth;

  final _transactionDataSource = TransactionDataSource();

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _initialPage);
    _baseMonth = DateTime.now();
  }

  DateTime _monthForIndex(int index) {
    final diff = index - _initialPage;
    return DateTime(_baseMonth.year, _baseMonth.month + diff);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      onPageChanged: (index) {
        widget.onMonthChanged?.call(_monthForIndex(index));
      },
      itemBuilder: (context, index) {
        final monthDate = _monthForIndex(index);

        return MonthPage(
          key: PageStorageKey(monthDate.toIso8601String()),
          monthDate: monthDate,
          dataSource: _transactionDataSource,
        );
      },
    );
  }
}
