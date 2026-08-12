import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main.dart');
});

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});

class SettingsState {
  final ThemeMode themeMode;
  final bool amoledMode;
  final bool dynamicColors;
  final int accentColor;
  final List<String> selectedFolders;

  final bool pauseHistory;
  final bool pauseSearchHistory;
  final int crossfadeDuration; // In seconds, 0 means disabled
  final bool autoplay;

  final bool wifiOnlyDownload;
  final bool autoCacheCleanup;
  final String streamingQuality;
  final bool wifiOnlyStreaming;

  SettingsState({
    this.themeMode = ThemeMode.system,
    this.amoledMode = false,
    this.dynamicColors = true,
    this.accentColor = 0xFF6200EE,
    this.selectedFolders = const [],

    this.pauseHistory = false,
    this.pauseSearchHistory = false,
    this.crossfadeDuration = 0,
    this.autoplay = true,
    this.wifiOnlyDownload = false,
    this.autoCacheCleanup = false,
    this.streamingQuality = 'Auto',
    this.wifiOnlyStreaming = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? amoledMode,
    bool? dynamicColors,
    int? accentColor,
    List<String>? selectedFolders,

    bool? pauseHistory,
    bool? pauseSearchHistory,
    int? crossfadeDuration,
    bool? autoplay,
    bool? wifiOnlyDownload,
    bool? autoCacheCleanup,
    String? streamingQuality,
    bool? wifiOnlyStreaming,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      amoledMode: amoledMode ?? this.amoledMode,
      dynamicColors: dynamicColors ?? this.dynamicColors,
      accentColor: accentColor ?? this.accentColor,
      selectedFolders: selectedFolders ?? this.selectedFolders,

      pauseHistory: pauseHistory ?? this.pauseHistory,
      pauseSearchHistory: pauseSearchHistory ?? this.pauseSearchHistory,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      autoplay: autoplay ?? this.autoplay,
      wifiOnlyDownload: wifiOnlyDownload ?? this.wifiOnlyDownload,
      autoCacheCleanup: autoCacheCleanup ?? this.autoCacheCleanup,
      streamingQuality: streamingQuality ?? this.streamingQuality,
      wifiOnlyStreaming: wifiOnlyStreaming ?? this.wifiOnlyStreaming,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  late SharedPreferences _prefs;
  static const _themeModeKey = 'theme_mode';
  static const _amoledModeKey = 'amoled_mode';
  static const _dynamicColorsKey = 'dynamic_colors';
  static const _accentColorKey = 'accent_color';
  static const _selectedFoldersKey = 'selected_folders';
  static const _crossfadeDurationKey = 'crossfade_duration';
  static const _autoplayKey = 'autoplay';
  static const _wifiOnlyKey = 'wifi_only_download';
  static const _autoCacheCleanupKey = 'auto_cache_cleanup';
  static const _streamingQualityKey = 'streaming_quality';
  static const _wifiOnlyStreamingKey = 'wifi_only_streaming';

  @override
  SettingsState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return SettingsState(
      themeMode: _loadThemeMode(_prefs),
      amoledMode: _prefs.getBool(_amoledModeKey) ?? false,
      dynamicColors: _prefs.getBool(_dynamicColorsKey) ?? true,
      accentColor: _prefs.getInt(_accentColorKey) ?? Colors.blue.toARGB32(),
      selectedFolders: _prefs.getStringList(_selectedFoldersKey) ?? [],

      pauseHistory: _prefs.getBool('pause_history') ?? false,
      pauseSearchHistory: _prefs.getBool('pause_search_history') ?? false,
      crossfadeDuration: _prefs.getInt(_crossfadeDurationKey) ?? 0,
      autoplay: _prefs.getBool(_autoplayKey) ?? true,
      wifiOnlyDownload: _prefs.getBool(_wifiOnlyKey) ?? false,
      autoCacheCleanup: _prefs.getBool(_autoCacheCleanupKey) ?? false,
      streamingQuality: _prefs.getString(_streamingQualityKey) ?? 'Auto',
      wifiOnlyStreaming: _prefs.getBool(_wifiOnlyStreamingKey) ?? false,
    );
  }

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final savedMode = prefs.getString(_themeModeKey);
    switch (savedMode) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    String value;
    switch (mode) {
      case ThemeMode.light: value = 'light'; break;
      case ThemeMode.dark: value = 'dark'; break;
      case ThemeMode.system: value = 'system'; break;
    }
    await _prefs.setString(_themeModeKey, value);
  }
  
  Future<void> updateAmoledMode(bool isAmoled) async {
    state = state.copyWith(amoledMode: isAmoled);
    await _prefs.setBool(_amoledModeKey, isAmoled);
  }

  Future<void> updateDynamicColors(bool useDynamic) async {
    state = state.copyWith(dynamicColors: useDynamic);
    await _prefs.setBool(_dynamicColorsKey, useDynamic);
  }

  Future<void> updateAccentColor(Color color) async {
    state = state.copyWith(accentColor: color.toARGB32());
    await _prefs.setInt(_accentColorKey, color.toARGB32());
  }

  Future<void> updateSelectedFolders(List<String> folders) async {
    state = state.copyWith(selectedFolders: folders);
    await _prefs.setStringList(_selectedFoldersKey, folders);
  }



  Future<void> updatePauseHistory(bool pause) async {
    state = state.copyWith(pauseHistory: pause);
    await _prefs.setBool('pause_history', pause);
  }

  Future<void> updatePauseSearchHistory(bool pause) async {
    state = state.copyWith(pauseSearchHistory: pause);
    await _prefs.setBool('pause_search_history', pause);
  }

  Future<void> updateCrossfadeDuration(int duration) async {
    state = state.copyWith(crossfadeDuration: duration);
    await _prefs.setInt(_crossfadeDurationKey, duration);
  }

  Future<void> updateAutoplay(bool autoplay) async {
    state = state.copyWith(autoplay: autoplay);
    await _prefs.setBool(_autoplayKey, autoplay);
  }

  Future<void> updateWifiOnlyDownload(bool wifiOnly) async {
    state = state.copyWith(wifiOnlyDownload: wifiOnly);
    await _prefs.setBool(_wifiOnlyKey, wifiOnly);
  }

  Future<void> updateAutoCacheCleanup(bool cleanup) async {
    state = state.copyWith(autoCacheCleanup: cleanup);
    await _prefs.setBool(_autoCacheCleanupKey, cleanup);
  }

  Future<void> updateStreamingQuality(String quality) async {
    state = state.copyWith(streamingQuality: quality);
    await _prefs.setString(_streamingQualityKey, quality);
  }

  Future<void> updateWifiOnlyStreaming(bool wifiOnly) async {
    state = state.copyWith(wifiOnlyStreaming: wifiOnly);
    await _prefs.setBool(_wifiOnlyStreamingKey, wifiOnly);
  }
}
