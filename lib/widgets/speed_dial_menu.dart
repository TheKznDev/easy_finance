// DEPRECATED: This widget is no longer in use.

import 'package:flutter/material.dart';

class SpeedDialMenu extends StatefulWidget {
  final VoidCallback onAddTransaction;
  final VoidCallback onAddGroup;

  const SpeedDialMenu({
    super.key,
    required this.onAddTransaction,
    required this.onAddGroup,
  });

  @override
  _SpeedDialMenuState createState() => _SpeedDialMenuState();
}

class _SpeedDialMenuState extends State<SpeedDialMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Empty widget
  }
}
