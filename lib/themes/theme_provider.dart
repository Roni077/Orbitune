import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    // TODO: Load from Hive/SharedPreferences later
    return const ThemeState();
  }

  void setTheme(ThemeType type) {
    state = state.copyWith(themeType: type);
    // TODO: Save to local storage
  }

  void toggleDynamicColor(bool useDynamic) {
    state = state.copyWith(useDynamicColor: useDynamic);
    // TODO: Save to local storage
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
