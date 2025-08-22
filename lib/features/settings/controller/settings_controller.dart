import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Settings state
class SettingsState {
  
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.enableReputationCheck = true,
    this.enableUrlExpansion = true,
    this.appVersion = '',
    this.buildNumber = '',
  });
  final ThemeMode themeMode;
  final bool enableReputationCheck;
  final bool enableUrlExpansion;
  final String appVersion;
  final String buildNumber;
  
  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? enableReputationCheck,
    bool? enableUrlExpansion,
    String? appVersion,
    String? buildNumber,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      enableReputationCheck: enableReputationCheck ?? this.enableReputationCheck,
      enableUrlExpansion: enableUrlExpansion ?? this.enableUrlExpansion,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsState &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          enableReputationCheck == other.enableReputationCheck &&
          enableUrlExpansion == other.enableUrlExpansion &&
          appVersion == other.appVersion &&
          buildNumber == other.buildNumber;
  
  @override
  int get hashCode =>
      themeMode.hashCode ^
      enableReputationCheck.hashCode ^
      enableUrlExpansion.hashCode ^
      appVersion.hashCode ^
      buildNumber.hashCode;
}

/// Settings controller
class SettingsController extends StateNotifier<SettingsState> {
  
  SettingsController() : super(const SettingsState()) {
    _loadSettings();
    _loadAppInfo();
  }
  static const _storage = FlutterSecureStorage();
  static const _themeModeKey = 'theme_mode';
  static const _reputationCheckKey = 'enable_reputation_check';
  static const _urlExpansionKey = 'enable_url_expansion';
  
  /// Load settings from secure storage
  Future<void> _loadSettings() async {
    try {
      final themeModeStr = await _storage.read(key: _themeModeKey);
      final reputationCheckStr = await _storage.read(key: _reputationCheckKey);
      final urlExpansionStr = await _storage.read(key: _urlExpansionKey);
      
      final themeMode = _parseThemeMode(themeModeStr);
      final enableReputationCheck = reputationCheckStr != 'false';
      final enableUrlExpansion = urlExpansionStr != 'false';
      
      state = state.copyWith(
        themeMode: themeMode,
        enableReputationCheck: enableReputationCheck,
        enableUrlExpansion: enableUrlExpansion,
      );
    } catch (e) {
      // Use default settings if loading fails
    }
  }
  
  /// Load app information
  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      state = state.copyWith(
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
      );
    } catch (e) {
      // Use default values if loading fails
    }
  }
  
  /// Set theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _storage.write(key: _themeModeKey, value: themeMode.name);
  }
  
  /// Toggle reputation check
  Future<void> setReputationCheck(bool enabled) async {
    state = state.copyWith(enableReputationCheck: enabled);
    await _storage.write(key: _reputationCheckKey, value: enabled.toString());
  }
  
  /// Toggle URL expansion
  Future<void> setUrlExpansion(bool enabled) async {
    state = state.copyWith(enableUrlExpansion: enabled);
    await _storage.write(key: _urlExpansionKey, value: enabled.toString());
  }
  
  /// Reset all settings to defaults
  Future<void> resetSettings() async {
    await _storage.deleteAll();
    state = const SettingsState();
    await _loadAppInfo();
  }
  
  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

/// Settings controller provider
final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsState>(
  (ref) => SettingsController(),
);

/// Theme mode provider (convenience)
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsControllerProvider).themeMode;
});

/// Reputation check enabled provider (convenience)
final reputationCheckEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).enableReputationCheck;
});

/// URL expansion enabled provider (convenience)
final urlExpansionEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).enableUrlExpansion;
});

/// App version provider (convenience)
final appVersionProvider = Provider<String>((ref) {
  final state = ref.watch(settingsControllerProvider);
  return '${state.appVersion}+${state.buildNumber}';
});
