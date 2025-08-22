import 'package:flutter/material.dart';

/// App theme configuration
class AppTheme {
  static const _primaryColor = Color(0xFF2E7D32); // Green for security
  static const _secondaryColor = Color(0xFF1976D2); // Blue for trust
  static const _errorColor = Color(0xFFD32F2F); // Red for danger
  static const _warningColor = Color(0xFFFF9800); // Orange for warning
  static const _successColor = Color(0xFF388E3C); // Green for success
  
  /// Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        error: _errorColor,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      extensions: const [
        AppColors.light,
      ],
    );
  }
  
  /// Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
        error: _errorColor,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      extensions: const [
        AppColors.dark,
      ],
    );
  }
}

/// Custom colors for the app
class AppColors extends ThemeExtension<AppColors> {
  
  const AppColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.safe,
    required this.suspicious,
  });
  final Color success;
  final Color warning;
  final Color danger;
  final Color safe;
  final Color suspicious;
  
  static const light = AppColors(
    success: Color(0xFF388E3C),
    warning: Color(0xFFFF9800),
    danger: Color(0xFFD32F2F),
    safe: Color(0xFF4CAF50),
    suspicious: Color(0xFFFF9800),
  );
  
  static const dark = AppColors(
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFB74D),
    danger: Color(0xFFEF5350),
    safe: Color(0xFF66BB6A),
    suspicious: Color(0xFFFFB74D),
  );
  
  @override
  ThemeExtension<AppColors> copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? safe,
    Color? suspicious,
  }) {
    return AppColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      safe: safe ?? this.safe,
      suspicious: suspicious ?? this.suspicious,
    );
  }
  
  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) return this;
    
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      safe: Color.lerp(safe, other.safe, t)!,
      suspicious: Color.lerp(suspicious, other.suspicious, t)!,
    );
  }
}

/// Extension to easily access custom colors
extension AppColorsExtension on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
