import 'package:flutter/material.dart';

class SummarySection extends StatelessWidget {
  final String title;
  final String selectedText;
  final VoidCallback onPickDateRange;
  final Widget summaryGrid;
  final Color accentColor;

  const SummarySection({
    super.key,
    required this.title,
    required this.selectedText,
    required this.onPickDateRange,
    required this.summaryGrid,
    this.accentColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: onPickDateRange,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(Icons.calendar_today, color: accentColor),
                ],
              ),
            ),
          ),
        ),
        summaryGrid,
      ],
    );
  }
}
