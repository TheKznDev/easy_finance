import 'package:flutter/material.dart';

/// Um gerenciador de tema simples que usa um ValueNotifier para notificar sobre mudanças.
class ThemeManager {
  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }
}

// Instância global para fácil acesso.
final themeManager = ThemeManager();
