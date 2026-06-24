import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';

enum ThemeType {
  light,
  dark,
  amoled,
  system,
  highContrast,
}

class ThemeState {
  final ThemeType themeType;
  final bool useDynamicColor;

  const ThemeState({
    this.themeType = ThemeType.system,
    this.useDynamicColor = true,
  });

  ThemeState copyWith({
    ThemeType? themeType,
    bool? useDynamicColor,
  }) {
    return ThemeState(
      themeType: themeType ?? this.themeType,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final typeIndex = prefs.getInt('theme_type') ?? ThemeType.system.index;
    final useDynamic = prefs.getBool('theme_dynamic_color') ?? true;
    
    return ThemeState(
      themeType: ThemeType.values[typeIndex],
      useDynamicColor: useDynamic,
    );
  }

  void setTheme(ThemeType type) {
    state = state.copyWith(themeType: type);
    ref.read(sharedPreferencesProvider).setInt('theme_type', type.index);
  }

  void toggleDynamicColor(bool useDynamic) {
    state = state.copyWith(useDynamicColor: useDynamic);
    ref.read(sharedPreferencesProvider).setBool('theme_dynamic_color', useDynamic);
  }

  ThemeMode get themeMode {
    switch (state.themeType) {
      case ThemeType.light:
        return ThemeMode.light;
      case ThemeType.dark:
      case ThemeType.amoled:
      case ThemeType.highContrast:
        return ThemeMode.dark;
      case ThemeType.system:
        return ThemeMode.system;
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);
